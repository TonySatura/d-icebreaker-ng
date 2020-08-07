import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { CacheSettings, CacheStorageType } from "../cache/models/cache.model";
import { CacheService } from "../cache/services/cache.service";
import { CACHE_SETTINGS } from "../cache/services/cache.config";

const QUESTIONS_CACHE_SETTINGS: CacheSettings = {
  enabled: true,
  expiresInSeconds: 24 * 60 * 60,
  storageType: CacheStorageType.IN_MEMORY,
};

@NgModule({
  imports: [CommonModule],
  providers: [
    CacheService,
    {
      provide: CACHE_SETTINGS,
      useValue: QUESTIONS_CACHE_SETTINGS,
    },
  ],
})
export class QuestionsModule {}
