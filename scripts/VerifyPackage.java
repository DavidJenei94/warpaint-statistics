import java.io.ByteArrayInputStream;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyFactory;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
import java.util.HashMap;
import java.util.HashSet;
import javax.xml.parsers.DocumentBuilderFactory;
import org.apache.commons.compress.archivers.sevenz.SevenZFile;
import org.w3c.dom.Element;
import com.garmin.connectiq.common.signing.KeyUtils;
import com.garmin.connectiq.common.signing.VerifyingUtils;

/** Inspect the actual Garmin IQ archive before accepting a release export. */
class VerifyPackage {
    @SuppressWarnings("deprecation")
    public static void main(String[] args) throws Exception {
        var expected = new HashSet<>(Files.readAllLines(Path.of(args[1])));
        var entries = new HashMap<String, byte[]>();
        try (var archive = new SevenZFile(new File(args[0]))) {
            for (var entry : archive.getEntries()) {
                if (!entry.isDirectory()) {
                    try (var input = archive.getInputStream(entry)) {
                        entries.put(entry.getName().replace('\\', '/'), input.readAllBytes());
                    }
                }
            }
        }
        var manifest = entries.get("manifest.xml");
        var signature = entries.get("manifest.sig2");
        var publicKey = entries.get("dev_key.pub");
        if (manifest == null || signature == null || publicKey == null) {
            throw new IllegalStateException("The IQ archive is missing its signed manifest or public key.");
        }
        var key = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(publicKey));
        var verifier = Signature.getInstance("SHA256withRSA");
        verifier.initVerify(key);
        verifier.update(manifest);
        if (!verifier.verify(signature)) {
            throw new IllegalStateException("The IQ manifest signature is invalid.");
        }
        var factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        var document = factory.newDocumentBuilder().parse(new ByteArrayInputStream(manifest));
        var application = (Element) document.getElementsByTagNameNS("http://www.garmin.com/xml/connectiq", "application").item(0);
        if (!application.getAttribute("id").equalsIgnoreCase(args[2].replace("-", ""))) {
            throw new IllegalStateException("The export changed the application ID.");
        }
        if (args.length >= 4 && !application.getAttribute("type").equals(args[3])) {
            throw new IllegalStateException("The export changed the application type.");
        }
        var products = document.getElementsByTagNameNS("http://www.garmin.com/xml/connectiq", "product");
        var actual = new HashSet<String>();
        for (int i = 0; i < products.getLength(); i++) {
            var product = (Element) products.item(i);
            actual.add(product.getAttribute("partNumber"));
            var program = entries.get(product.getAttribute("filename"));
            if (program == null || program.length == 0) {
                throw new IllegalStateException("Missing binary for " + product.getAttribute("partNumber"));
            }
            var programSignature = VerifyingUtils.getVerifiedDeveloperSignature(program);
            var programKey = KeyUtils.generatePublicKey(programSignature.getModulusBytes(), programSignature.getExponentAsInt());
            if (!java.util.Arrays.equals(key.getEncoded(), programKey.getEncoded())) {
                throw new IllegalStateException("Binary signed with a different key for " + product.getAttribute("partNumber"));
            }
        }
        if (!actual.equals(expected)) {
            var missing = new HashSet<>(expected);
            missing.removeAll(actual);
            var unexpected = new HashSet<>(actual);
            unexpected.removeAll(expected);
            throw new IllegalStateException("Device coverage differs: missing=" + missing + ", unexpected=" + unexpected);
        }
        System.out.println("Verified signed manifest and " + actual.size() + " device variant binaries.");
    }
}
