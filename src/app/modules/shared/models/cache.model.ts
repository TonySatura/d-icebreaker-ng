export interface CacheObject {
  data: any;
  expireDate?: Date;
}

export interface CacheSettings {
  enabled: boolean;
  expiresInSeconds: number;
  storageType: CacheStorageType;
}

export interface ICacheStorage {
  save(cacheKey: string, cacheObject: CacheObject);
  load<TData>(cacheKey: string): TData;
}

export enum CacheStorageType {
  IN_MEMORY,
  LOCAL_STORAGE,
}
