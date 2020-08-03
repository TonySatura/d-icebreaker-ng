import { Component, OnInit } from "@angular/core";
import { QuestionService } from "./services/question.service";

@Component({
  selector: "app-root",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.scss"],
})
export class AppComponent implements OnInit {
  title = "d-icebreaker-ng";
  questionHead = "";
  questionBody = "";

  constructor(private questionService: QuestionService) {}

  ngOnInit() {
    this.loadQuestion();
  }

  onClick() {
    this.loadQuestion();
  }

  private loadQuestion() {
    const maxHeaderLength = 10;

    this.questionService.getRandomQuestion().subscribe((q) => {
      // console.log("loadQuestion");
      const words = q.split(" ");
      this.questionHead = "";
      this.questionBody = "";

      // console.log(words);

      for (const word of words) {
        if (
          this.questionHead === "" ||
          this.questionHead.length + 1 + word.length < maxHeaderLength
        ) {
          this.questionHead += word + " ";
        } else {
          this.questionHead.trim();
          this.questionBody = q.substring(this.questionHead.length);
          return;
        }
      }
    });
  }
}
