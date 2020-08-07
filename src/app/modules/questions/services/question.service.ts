import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";
import { CacheService } from "../../shared/services/cache.service";

@Injectable({
  providedIn: "root",
})
export class QuestionService {
  constructor(private http: HttpClient, private cacheService: CacheService) {}

  public getRandomQuestion(): Observable<string> {
    return this.getQuestions().pipe(
      map((questions) => this.getRandomElement(questions))
    );
  }

  private getQuestions(): Observable<string[]> {
    // TODO: Add Cache Service (see image-gallery-ng)

    return this.cacheService.getObservable(null, (r) => {
      const fileObservable = this.http.get("assets/questions.txt", {
        responseType: "text",
      });

      return fileObservable.pipe(map((questions) => questions.split("\n")));
    });
  }

  private getRandomElement<T>(array: Array<T>) {
    return array[this.getRandomNumber(0, array.length - 1)];
  }

  private getRandomNumber(min: number, max: number) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
}
