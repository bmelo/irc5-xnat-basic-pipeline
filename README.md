# IRC5 XNAT - basic-pipeline
XNAT basic pipeline

## How to Build
```
docker build -t irc5/basic-pipeline:latest -t irc5/basic-pipeline:1.0 .
docker push irc5/basic-pipeline:latest
docker push irc5/basic-pipeline:1.0
```

## Preparing image to be recognized as a XNAT command:

1. Run the command below and copy the output.
```
python ./command2label.py ./command.json
```

2. Update last line of the Dockerfile pasting the output of the previous command.


## Testing
```
docker run -it --rm --entrypoint bash \
    irc5/basic-pipeline:latest
```
