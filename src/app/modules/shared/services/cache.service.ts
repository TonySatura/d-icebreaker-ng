import { Injectable, Inject } from "@angular/core";
import { Observable, of, race } from "rxjs";
import { share, tap } from "rxjs/operators";
import { environment } from "src/environments/environment";
import {
  CacheObject,
  CacheSettings,
  ICacheStorage,
  CacheStorageType,
} from "../models/cache.model";
import { CACHE_SETTINGS } from "./cache.config";
import { InMemoryCacheStorage } from "./in-memory-cache-storage";
import { DomCacheStorage } from "./dom-cache-storage";

@Injectable()
export class CacheService {
  private storage: ICacheStorage;
  private settings: CacheSettings;

  constructor(@Inject(CACHE_SETTINGS) settings: CacheSettings) {
    this.settings = settings;

    if (this.settings.enabled) {
      switch (this.settings.storageType) {
        case CacheStorageType.LOCAL_STORAGE:
          this.storage = new DomCacheStorage();
          break;
        default:
        case CacheStorageType.IN_MEMORY:
          this.storage = new InMemoryCacheStorage();
          break;
      }
    }
  }

  public getObservable<T, TResult>(
    request: T,
    cachedFunction: (r: T) => Observable<TResult>
  ): Observable<TResult> {
    const result: TResult = this.loadFromCache<T, TResult>(request);
    let observable: Observable<TResult>;

    if (result) {
      observable = of(result);
    } else {
      if (!environment.production) {
        console.log("=== NOT FROM CACHE ===");
      }

      observable = cachedFunction(request).pipe(
        tap((response) => {
          if (!environment.production) {
            console.log(response);
          }
        }),
        share()
      );

      observable.subscribe((r: TResult) => {
        this.saveToCache<T, TResult>(
          request,
          r,
          this.settings.expiresInSeconds
        );
      });
    }

    return observable;
  }

  private getCacheKey<T>(request: T) {
    return btoa(JSON.stringify(request));
  }

  private loadFromCache<T, TResult>(request: T): TResult {
    if (this.storage) {
      const cacheKey = this.getCacheKey(request);
      return this.storage.load<TResult>(cacheKey);
    }
  }

  private saveToCache<T, TResult>(
    request: T,
    result: TResult,
    expiresInSeconds: number
  ) {
    if (this.storage) {
      const cacheKey = this.getCacheKey(request);

      const cacheObject = {
        data: result,
        expireDate: this.calculateExpireDate(expiresInSeconds),
      } as CacheObject;

      this.storage.save(cacheKey, cacheObject);
    }
  }

  private calculateExpireDate(expiresInSeconds: number) {
    const expireDate = new Date();
    expireDate.setSeconds(expireDate.getSeconds() + expiresInSeconds);
    return expireDate;
  }
}
