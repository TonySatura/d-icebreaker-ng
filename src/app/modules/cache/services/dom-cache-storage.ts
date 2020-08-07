import { ICacheStorage, CacheObject } from '../models/cache.model';

export class DomCacheStorage implements ICacheStorage {
    constructor() {}

    public save(cacheKey: string, cacheObject: CacheObject) {
        localStorage.setItem(cacheKey, JSON.stringify(cacheObject));
    }

    public load<TResult>(cacheKey: string): TResult {
        const cacheObject: CacheObject = JSON.parse(
            localStorage.getItem(cacheKey)
        );

        if (cacheObject) {
            // Because of stringified storage, Date must be parsed again
            const expireDate = new Date(cacheObject.expireDate);

            if (new Date() < expireDate) {
                return cacheObject.data;
            } else {
                localStorage.removeItem(cacheKey);
            }
        }
    }
}
