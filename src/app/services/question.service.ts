import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";

@Injectable({
  providedIn: "root",
})
export class QuestionService {
  constructor(private http: HttpClient) {}

  public getRandomQuestion(): Observable<string> {
    return this.getQuestions().pipe(
      map((questions) => this.getRandomElement(questions))
    );
  }

  private getQuestions(): Observable<string[]> {
    const fileObservable = this.http.get("assets/questions.txt", {
      responseType: "text",
    });

    const questionsObservable = fileObservable.pipe(
      map((questions) => questions.split("\n"))
    );

    return questionsObservable;
  }

  private getRandomElement<T>(array: Array<T>) {
    return array[Math.floor(Math.random() * array.length)];
  }
}
