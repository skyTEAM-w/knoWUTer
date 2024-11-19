import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import Logger from './Logger';

export class CryptoUtil {
  public static genSymKeyByData(symKeyData: Uint8Array, algName: string): cryptoFramework.SymKey {
    let symKeyBlob: cryptoFramework.DataBlob = { data: symKeyData };
    let aesGenerator = cryptoFramework.createSymKeyGenerator(algName);
    let symKey = aesGenerator.convertKeySync(symKeyBlob);
    Logger.info('convertKey success');
    return symKey;
  }

  public static async encryptMessagePromise(cipherParam: string, symKey: cryptoFramework.SymKey,
    plainText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob> {
    let cipher = cryptoFramework.createCipher(cipherParam);
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, null);
    let cipherData = await cipher.doFinal(plainText);
    return cipherData;
  }

  public static async encryptPublicKeyMessagePromise(cipherParam: string, publicKey: cryptoFramework.PubKey,
    plainText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob> {
    let cipher = cryptoFramework.createCipher(cipherParam);
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, publicKey, null);
    let cipherData = await cipher.doFinal(plainText);
    return cipherData;
  }

  public static genKeyPairByData(algName: string, pubKeyData: Uint8Array,
    priKeyData: Uint8Array): cryptoFramework.KeyPair {
    let pubKeyBlob: cryptoFramework.DataBlob = { data: pubKeyData };
    let priKeyBlob: cryptoFramework.DataBlob = { data: priKeyData };
    let rsaGenerator = cryptoFramework.createAsyKeyGenerator(algName);
    let keyPair = rsaGenerator.convertKeySync(pubKeyBlob, priKeyBlob);
    return keyPair;
  }

  public static genKeyPairByPubKey(algName: string, pubKeyData: Uint8Array) {
    let pubKeyBlob: cryptoFramework.DataBlob = { data: pubKeyData };
    let rsaGenerator = cryptoFramework.createAsyKeyGenerator(algName);
    let keyPair = rsaGenerator.convertKeySync(pubKeyBlob, null);
    return keyPair;
  }
}