# sharp-heif-lambda-layer

A simple build script to create a Lambda layer for [Sharp](https://sharp.pixelplumbing.com/) with support for [HEIF](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format) files. In order to run the build [Docker](https://www.docker.com/) needs to be installed on your build system.

To create the Lambda layer artifact run simply:

```
./run.sh
```

It will create a pre-tested zip file. The zip file can easily integrated in IaC pipelines or for manual use.

**The default compilation specifically targets decoders**, meaning that HEIF files can be read but not written. If you want to use encoders (for writing HEIF files) you can enable HEVC or AV1 encoding:

```
./run.sh --with-hevc-encoder --with-av1-encoder
```

The default script is targeting the `x86_64` platform. To build for `arm64` run:

```
./run.sh --build-target-arm64
```
