# crossplane-multicloud

Set sso admin email

```bash
aws secretsmanager create-secret --region us-east-1 --name "cloud/pub/sso" \
 --description 'Email Address off sso admin' \
 --kms-key-id "alias/aws/secretsmanager" \
 --tags '[{"Key":"logsr.life/owner","Value":"...."},{"Key":"logsr.life/environment","Value":"production"},{"Key":"logsr.life/tier","Value":"control-plane"},{"Key":"logsr.life", "Value":"partition"}]' \
 --add-replica-regions '[{"Region": "us-west-1","KmsKeyId": "alias/aws/secretsmanager"}]' \
 --secret-string '{"akadminEmail":"......"}'
```
