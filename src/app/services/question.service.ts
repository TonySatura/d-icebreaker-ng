import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";

@Injectable({
  providedIn: "root",
})
export class QuestionService {
  private questionsObservable: Observable<string[]> = null;

  constructor(private http: HttpClient) {}

  public getRandomQuestion(): Observable<string> {
    return this.getQuestions().pipe(
      map((questions) => this.getRandomElement(questions))
    );
  }

  private getQuestions(): Observable<string[]> {
    if (this.questionsObservable == null) {
      const fileObservable = this.http.get("assets/questions.txt", {
        responseType: "text",
      });

      this.questionsObservable = fileObservable.pipe(
        map((questions) => questions.split("\n"))
      );
    }

    return this.questionsObservable;
  }

  private getRandomElement<T>(array: Array<T>) {
    return array[this.getRandomNumber(0, array.length - 1)];
  }

  public getRandomNumber(min: number, max: number) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
}
