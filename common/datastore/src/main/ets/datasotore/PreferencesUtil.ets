import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const PREFERENCES_NAME: string = 'ApplicationPreferences';

export class PreferencesUtil {
  private static instance: PreferencesUtil;
  private preferences?: preferences.Preferences;
  private context = getContext(this) as common.UIAbilityContext;

  private constructor() {
    this.initPreference(PREFERENCES_NAME);
  }

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  async initPreference(preferenceName: string): Promise<void> {
    return preferences.getPreferences(this.context, preferenceName).then((preferences: preferences.Preferences) => {
      this.preferences = preferences;
    });
  }

  async setValue<T>(key: string, value: T): Promise<void> {
    if (this.preferences) {
      this.preferences.put(key, JSON.stringify(value)).then(() => {
        this.saveUserData();
      })
    } else {
      this.initPreference(PREFERENCES_NAME).then(() => {
        this.setValue<T>(key, value);
      });
    }
  }

  async getValue<T>(key: string): Promise<T | null> {
    if (this.preferences) {
      return this.preferences.get(key, '').then((res: preferences.ValueType) => {
        let value: T | null = null;
        if (res) {
          value = JSON.parse(res as string) as T;
        }
        return value;
      });
    } else {
      return this.initPreference(PREFERENCES_NAME).then(() => {
        return this.getValue<T>(key);
      });
    }
  }

  async hasValue(key: string): Promise<boolean> {
    if (this.preferences) {
      return this.preferences.has(key);
    } else {
      return this.initPreference(PREFERENCES_NAME).then(() => {
        return this.hasValue(key);
      });
    }
  }

  async deleteValue(key: string): Promise<void> {
    if (this.preferences) {
      this.preferences.delete(key).then(() => {
        this.saveUserData();
      });
    } else {
      this.initPreference(PREFERENCES_NAME).then(() => {
        this.deleteValue(key);
      });
    }
  }

  saveUserData() {
    this.preferences?.flush();
  }
}

