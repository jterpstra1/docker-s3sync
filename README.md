# s3sync

A small container that backs up folders to Amazon S3 on a schedule. Mount what you want backed up under `/data`, point it at a bucket, and it runs `aws s3 sync` (AWS CLI v2) from cron.

```
ghcr.io/jterpstra1/docker-s3sync
```

Built for `linux/amd64` and `linux/arm64`.

## Quick start

Back up `/home/user` to a bucket every hour:

```bash
docker run -d --name s3sync \
  -v /home/user:/data/user:ro \
  -e ACCESS_KEY=AKIA... \
  -e SECRET_KEY=... \
  -e REGION=eu-west-1 \
  -e S3PATH=s3://my-bucket \
  ghcr.io/jterpstra1/docker-s3sync
```

Each folder under `/data` ends up as a prefix in the bucket, so `/data/user/notes.txt` becomes `s3://my-bucket/user/notes.txt`. Mount sources read-only (`:ro`); the container only reads them.

## Docker Compose

```yaml
services:
  s3sync:
    image: ghcr.io/jterpstra1/docker-s3sync:latest
    restart: unless-stopped
    volumes:
      - /home/user:/data/user:ro
      - /opt/files:/data/files:ro
    environment:
      ACCESS_KEY: AKIA...
      SECRET_KEY: ...
      REGION: eu-west-1
      S3PATH: s3://my-bucket/backups
      S3SYNCPARAMS: --delete --storage-class GLACIER_IR
      CRON_SCHEDULE: "0 3 * * *"
```

## Settings

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `ACCESS_KEY` | yes | | AWS access key ID |
| `SECRET_KEY` | yes | | AWS secret access key |
| `REGION` | yes | | Region of the bucket, for example `eu-west-1` |
| `S3PATH` | yes | | Destination bucket, optionally with a prefix: `s3://my-bucket/backups` |
| `CRON_SCHEDULE` | no | `0 * * * *` (hourly) | When to sync, in [cron syntax](https://crontab.guru) |
| `S3SYNCPARAMS` | no | | Extra flags for [`aws s3 sync`](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html) |

Common `S3SYNCPARAMS`:

- `--delete` removes objects from the bucket (under `S3PATH`) that no longer exist locally. Without it, deleted files stay in S3.
- `--storage-class GLACIER_IR` or `STANDARD_IA` stores backups in a cheaper storage class.
- `--exclude "*.tmp"` skips matching files. Repeat it for more patterns.
- `--dryrun` shows what would be uploaded or deleted without doing it. Useful the first time you use `--delete`.

## How it behaves

- **The first sync runs on the schedule, not at startup.** With the hourly default that means up to an hour of waiting. To sync right away, run:

  ```bash
  docker exec s3sync /run.sh backup
  ```

- **Runs never overlap.** A lock file stops a new run while the previous one is still busy. The lock is removed when a run ends, also when it fails.
- **Output goes to the container log.** Follow it with `docker logs -f s3sync`.
- **Only changes are uploaded.** `aws s3 sync` compares size and modification time, so after the first run only new and changed files are sent.

## AWS permissions

Create an IAM user for the backup with only what it needs on the target bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-bucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

`s3:DeleteObject` is only needed when you use `--delete`.

## Unraid

A Community Applications template is in [jterpstra1/unraid-templates](https://github.com/jterpstra1/unraid-templates). It sets up the same container as above; add a path mapping under `/data/...` for each share you want backed up.

## Docker Hub

Versions up to 0.0.4 were published to Docker Hub as `jvdgt/docker-s3sync`. Those images stay available but get no updates; the arm64 build there cannot run the AWS CLI. Switch to `ghcr.io/jterpstra1/docker-s3sync`.

## Releases

Images are built and pushed by GitHub Actions when a `v*` tag is pushed. Pull requests are built but never pushed. Renovate keeps the base image, AWS CLI and actions up to date.
