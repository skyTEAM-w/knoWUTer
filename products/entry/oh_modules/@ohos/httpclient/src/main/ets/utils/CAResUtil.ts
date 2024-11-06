/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { Response } from '../response/Response';

export class CAResUtil {
  constructor() {
  }

  async getCA(ca, context): Promise<string> {
    if (!ca) {
      return "adapter getCA is error";
    }
    const value = await new Promise<Uint8Array>((resolve,reject) => {
      context.resourceManager.getRawFileContent(
        ca,
        (err: Response, value) => {
          if (err) {
            reject(err)
          }
          resolve(value);
        });
    })

    const rawFile: Uint8Array = value;
    return this.parsingRawFile(rawFile);
  }

  private parsingRawFile(rawFile: Uint8Array): string {
    let fileContent: string = "";
    for (let index = 0, len = rawFile.length; index < len; index++) {
      const todo = rawFile[index];
      const item = String.fromCharCode(todo);
      fileContent += item + "";
    }
    return fileContent;
  }
}