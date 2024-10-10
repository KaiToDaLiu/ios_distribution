const forge = require('node-forge');

function randomIV() {
    return forge.util.bytesToHex(forge.random.getBytesSync(16))
}

function aesEncryptBase64(key, iv, plaintext) {
    const cipher = forge.cipher.createCipher("AES-CBC", key);
    cipher.start({ iv: iv });
    cipher.update(forge.util.createBuffer(plaintext, "utf8"));
    cipher.finish();
    const encrypted = cipher.output; // hex -> base64
    const encryptedData = forge.util.encode64(encrypted.getBytes())
    return encryptedData;
}

function aesDecryptBase64(key, iv, encryptedText) {
    var decipher = forge.cipher.createDecipher("AES-CBC", key);
    decipher.start({ iv: iv });
    decipher.update(forge.util.createBuffer(forge.util.decode64(encryptedText)));
    var result = decipher.finish();
    if (!result) {
        console.log("decrypted failed,", encryptedText)
    }
    return decipher.output.toString();
}

const key = "f4k9f5w7f8g4er26"
const iv = randomIV()
const data = '{"userId":"u_b2d8ba87-f826-418a-9f2b-0615359add84","email":"yagai@kaito.ai","created":"2023-09-12T10:49:08.679Z","project":"Testing","customerType":"Project Team"}'

console.log(key)
console.log(iv)
console.log(data)
const aesEncoded = aesEncryptBase64(key, iv, data)
console.log(aesEncoded)
console.log(aesDecryptBase64(key, iv, aesEncoded))