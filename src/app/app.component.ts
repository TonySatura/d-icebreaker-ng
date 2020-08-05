import { Component, OnInit } from "@angular/core";
import {
  animate,
  style,
  transition,
  trigger,
  AnimationEvent,
} from "@angular/animations";
import { QuestionService } from "./modules/questions/services/question.service";

@Component({
  selector: "app-root",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.scss"],
  animations: [
    trigger("fadeTrigger", [
      transition(":enter", [
        style({ opacity: 0 }),
        animate("0.8s", style({ opacity: 1 })),
      ]),
      transition(":leave", [animate("0.2s", style({ opacity: 0 }))]),
    ]),
  ],
})
export class AppComponent implements OnInit {
  questionHead = "";
  questionBody = "";

  constructor(private questionService: QuestionService) {}

  ngOnInit() {
    this.loadQuestion();
  }

  onClick() {
    this.questionHead = "";
    this.questionBody = "";
  }

  public onFadeEvent(event: AnimationEvent) {
    if (event.fromState !== "void") {
      if (event.phaseName === "done") {
        console.log("next question requested");
        this.loadQuestion();
      }
    }
  }

  private loadQuestion() {
    const maxHeaderLength = 10;

    this.questionService.getRandomQuestion().subscribe((q) => {
      // console.log("loadQuestion");
      const words = q.split(" ");

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
