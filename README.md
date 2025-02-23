# s3sync
## Info
S3sync is a Docker container which backs up one or more folders to S3 using the AWS CLI v2 tool. 

## Usage

This container makes use of the `aws s3 sync` command. 

To tell s3sync what to back up,  mount your desired volumes under the `/data` directory.

s3sync is configured by setting the following environment variables during the launch of the container.

### Env variables
Env var | Description | Example
--- | --- | ---
`ACCESS_KEY` | your AWS access key | `AKIABV38RBV38RBV38B3`
`SECRET_KEY` | your AWS secret key | `ubuUbuBubUuuBbuveubviurvurud6rDU3qpU`
`REGION` | your bucket's region | `eu-west-1`
`S3PATH` | your S3 bucket and path | `s3://my-nice-bucket`
`S3SYNCPARAMS` | [custom parameters to aws s3 sync](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/sync.html) | `--delete --storage-class GLACIER_IR`

### Cron schedule
Files are by default backed up once every hour. You can customize this behavior
using an environment variable which uses the standard CRON notation.
`CRON_SCHEDULE` is set to `0 * * * *` by default, which means every hour. *I would advise against setting this to a more frequent schedule.*

## Example invocation

### Simple run
This will sync your `/home/user` local directory every hour to your specified S3 bucket, leaving everything else in the bucket intact.

```
docker run \
-v /home/user:/data/user:ro \
-e "ACCESS_KEY=AWS_ACCESS_KEY_HERE" \
-e "SECRET_KEY=AWS_SECRET_KEY_HERE" \
-e "REGION=eu-central-1" \
-e "S3PATH=s3://BUCKET_NAME_HERE" \
jvdgt/docker-s3sync
```

### Advanced run
If you want more customization on the S3 side, you can use the `S3SYNCPARAMS` to input `aws s3 sync` CLI parameters such as `--delete`. You can also specify deeper paths in S3, and a cron schedule.

This will sync both the `/home/user` and `/opt/files` local folders to `s3://your-bucket-name/this_prefix/` and **delete everything else** that's *inside that prefix*. Upon sync, the contents of `s3://your-bucket-name/this_prefix/` will only be the two folders [and their files] that you just synced.

```
docker run \
-v /home/user:/data/user:ro \
-v /opt/files:/data/files:ro\
-e "ACCESS_KEY=AWS_ACCESS_KEY_HERE" \
-e "SECRET_KEY=AWS_SECRET_KEY_HERE" \
-e "REGION=eu-central-1" \
-e "S3PATH=s3://BUCKET_NAME_HERE/this_prefix" \
-e "S3SYNCPARAMS=--delete --storage-class GLACIER_IR" \
-e "CRON_SCHEDULE=* 0 * * *" \
jvdgt/docker-s3sync
```

<!-- ## Unraid
s3sync is available on the Unraid Community Applications. See the [Support Thread](https://forums.unraid.net/topic/106320-support-what-name-s3sync/?tab=comments#comment-979903) for more information, or search for `s3sync` in CA. -->
