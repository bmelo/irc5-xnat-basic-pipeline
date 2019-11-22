# IRC5 XNAT - basic-pipeline
XNAT basic pipeline

## How to Build
```
docker build -t irc5/basic-pipeline:latest -t irc5/basic-pipeline:1.0 .
docker push irc5/basic-pipeline:latest
docker push irc5/basic-pipeline:1.0
```

## To get Command LABEL:
```
python ./command2label.py ./command.json
```

# How to test
```
docker run -it --rm --entrypoint bash \
    irc5/basic-pipeline:latest
```