# hf-ter

## The Issue (already resolved with the latest commit)

This repository demonstrates a bug while building `text-embedder-router` from [Hugging Face](https://github.com/huggingface/text-embeddings-inference/blob/v.1.1.0/README.md#cpu).

The goal is to demonstrate that the success of the build process on GitHub shared runners, while specifiying the `platform: linux/amd64` is building successfully, but the it is not running on local machine with *intel* or *m1* cpu.

## Steps to reproduce

* Build the docker image on **GitHub Shared Runner**
  * the github action is pushing the code to dockerhub registry
  * Confirm the build is successfull (check [github action output, section Test](https://github.com/yyovkov/hf-ter/actions/runs/8110753854/job/22168637202))

* Run the docker image on your local *intel* or *m1* (*m2*, *m3*) machine

    ``` bash
    docker run -ti --rm --platform linux/amd64 yyovkov/hf-ter:latest bash
    ```

* Execute *text-embeder-router* command inside the docker container and notice the error

    ``` bash
    $ root@9770c527dcd2:/# text-embeddings-router 
    Illegal instruction
    ```
