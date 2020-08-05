# DIcebreakerNg

This Angular application generates randomly icebreaker questions for meetings. Example: 'If you could have any super power, what would it be?'

## Deployment

Open CDK project [d-icebreaker-cdk](https://github.com/TonySatura/d-icebreaker-cdk)
    
  - compile TypeScript:
  
      `$ npm run build`

  - Deploy web application infrastructure and CodePipeline

      ```bash
      $ cdk deploy *-ui -c branch=master
      $ cdk deploy *-pipeline -c branch=master
      ```

  - Output:
      - siteURL = https://[...].cloudfront.net

  - Wait until the pipeline deployed the Angular project to the bucket for the first time
  
  - Visit the siteURL to test the web application

