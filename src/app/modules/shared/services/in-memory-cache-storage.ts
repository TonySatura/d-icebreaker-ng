import { ICacheStorage, CacheObject } from "../models/cache.model";

export class InMemoryCacheStorage implements ICacheStorage {
  private cacheMap: Map<string, CacheObject>;

  constructor() {
    this.cacheMap = new Map<string, CacheObject>();
  }

  public save(cacheKey: string, cacheObject: CacheObject) {
    this.cacheMap.set(cacheKey, cacheObject);
  }

  public load<TResult>(cacheKey: string): TResult {
    const cacheObject = this.cacheMap.get(cacheKey);

    if (cacheObject) {
      if (new Date() < cacheObject.expireDate) {
        return cacheObject.data;
      } else {
        this.cacheMap.delete(cacheKey);
      }
    }
  }
}
