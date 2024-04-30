# sharp-heif-lambda-layer

A simple build script to create a Lambda layer for [Sharp](https://sharp.pixelplumbing.com/) with support for [HEIF](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format) files. In order to run the build [Docker](https://www.docker.com/) needs to be installed on your build system.

To create the Lambda layer artifact run simply:

```
./run.sh
```

It will create a pre-tested zip file. The zip file can easily integrated in IaC pipelines or for manual use.

> The compilation process specifically targets decoders, meaning that HEIF files can be read and not written.
