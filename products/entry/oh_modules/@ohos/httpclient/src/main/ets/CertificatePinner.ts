/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import cryptoFramework from '@ohos.security.cert';
import { HttpUrl } from './HttpUrl';
import CryptoJS from '@ohos/crypto-js';
import Base64 from 'base64-js';
import socket from '@ohos.net.socket';

class Pin {
  private static readonly WILDCARD: string = '*.';
  readonly pattern: string;
  readonly canonicalHostname: string;
  readonly hashAlgorithm: string;
  readonly hash: string;

  constructor(pattern: string, pin: string) {
    this.pattern = pattern;
    this.canonicalHostname = this.normalizeHostname(pattern);

    if (pin.startsWith('sha1/')) {
      this.hashAlgorithm = "sha1/";
      this.hash = pin.substring('sha1/'.length);
    } else if (pin.startsWith('sha256/')) {
      this.hashAlgorithm = "sha256/";
      this.hash = pin.substring('sha256/'.length);
    } else {
      throw new Error("pins must start with 'sha256/' or 'sha1/':" + pin);
    }

    if (!this.hash) {
      throw new Error("pins must be base64: " + pin);
    }
  }

  private normalizeHostname(hostname: string): string {
    return  HttpUrl.get('http://' + this.pattern).getHost();
  }
}

export default class CertificatePinnerBuilder {
  private readonly pins: Pin[] = [];

  add(pattern: string, pin: string): CertificatePinnerBuilder {
    if (pattern === null) {
      throw new Error('pattern is null');
    }
    this.pins.push(new Pin(pattern, pin));
    return this;
  }

  build(): CertificatePinner {
    return new CertificatePinner(this.pins);
  }
}

export class CertificatePinner {
  private readonly pins: Pin[];
  private remoteCertSubName: string;
  private remoteCert256: string;
  private remoteCert1: string;
  res: string;

  constructor(pins: Pin[]) {
    this.pins = pins;
  }

  private toSHA(hash: string) {
    let remoteCertKey1 = CryptoJS.SHA1(CryptoJS.enc.Base64.parse(hash)).toString(CryptoJS.enc.Hex);
    let remoteCertKey256 = CryptoJS.SHA256(CryptoJS.enc.Base64.parse(hash)).toString(CryptoJS.enc.Hex);
    this.remoteCert1 = CryptoJS.enc.Base64.stringify(CryptoJS.enc.Hex.parse(remoteCertKey1))
    this.remoteCert256 = CryptoJS.enc.Base64.stringify(CryptoJS.enc.Hex.parse(remoteCertKey256))
  }

  private Uint8ArrayToString(fileData: Uint8Array): string {
    let dataString = "";
    for (let i = 0; i < fileData.length; i++) {
      dataString += String.fromCharCode(fileData[i]);
    }
    return dataString;
  }

  private getHostname(hostArray: Uint8Array) {
    let hostStrArray = this.Uint8ArrayToString(hostArray).split('/');
    for (let i of hostStrArray) {
      if (i.startsWith('CN=')) {
        return i.substring('CN='.length).replace(/\u0000/g, '');
      }
    }
    throw new Error('CertificatePinner check:get hostname fail');
  }

  async check(certData: socket.X509CertRawData) {
    const realCert = await cryptoFramework.createX509Cert(certData);
    const key = realCert.getItem(cryptoFramework.CertItemType.CERT_ITEM_TYPE_PUBLIC_KEY)
    this.toSHA(Base64.fromByteArray(key.data))
    this.remoteCertSubName = this.getHostname(realCert.getSubjectName().data) as string;
    for (let i = 0; i < this.pins.length; i++) {
      if (this.pins[i].canonicalHostname === this.remoteCertSubName) {
        if (this.pins[i].hashAlgorithm === 'sha1/' && this.pins[i].hash === this.remoteCert1) {
          console.log('CertificatePinner check OK');
          return;
        } else if (this.pins[i].hashAlgorithm === 'sha256/' && this.pins[i].hash === this.remoteCert256) {
          console.log('CertificatePinner check OK');
          return;
        }
      }
    }
    return 'CertificatePinner check--All SHA and hostname values does not match,please check.';
  }
}

export interface CertByJSON {
  hostname: string;
  digest_algorithm: string;
  digest: string;
}