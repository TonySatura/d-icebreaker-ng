import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CacheService } from './services/cache.service';
import {
    CACHE_SETTINGS,
    DEFAULT_CACHE_SETTINGS
} from './services/cache.config';

@NgModule({
    imports: [CommonModule],
    providers: [
        CacheService,
        {
            provide: CACHE_SETTINGS,
            useValue: DEFAULT_CACHE_SETTINGS
        }
    ]
})
export class CacheModule {}
