import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { SharedModule } from "../shared/shared.module";
import { CacheService } from "../shared/services/cache.service";
import { CacheSettings, CacheStorageType } from "../shared/models/cache.model";
import { CACHE_SETTINGS } from "../shared/services/cache.config";

const QUESTIONS_CACHE_SETTINGS: CacheSettings = {
  enabled: true,
  expiresInSeconds: 10 * 60,
  storageType: CacheStorageType.IN_MEMORY,
};

@NgModule({
  imports: [CommonModule, SharedModule],
  providers: [
    CacheService,
    {
      provide: CACHE_SETTINGS,
      useValue: QUESTIONS_CACHE_SETTINGS,
    },
  ],
})
export class QuestionsModule {}
