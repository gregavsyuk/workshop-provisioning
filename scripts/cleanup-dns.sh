echo '----> Cleaning up DNS records'

rm -f transaction.yaml

gcloud config set project $DNS_PROJECT

# Grab the current IP address of the DNS record
OLD_IP=$(gcloud dns record-sets list --zone=$DNS_ZONE | grep *.$WILDCARD_HOSTNAME | awk '{print $4}')
CURRENT_TTL=$(gcloud dns record-sets list --zone=$DNS_ZONE | grep *.$WILDCARD_HOSTNAME | awk '{print $3}')

# Start the transaction
if [[ $OLD_IP ]]; then
  gcloud dns record-sets transaction start --zone=$DNS_ZONE
  gcloud dns record-sets transaction remove $OLD_IP --name=*.$WILDCARD_HOSTNAME \
  --ttl=$CURRENT_TTL --type="A" --zone=$DNS_ZONE
  # Run the transaction
  gcloud dns record-sets transaction execute --zone=$DNS_ZONE
fi

# Switch back to the main GCP project
gcloud config set project $CLUSTER_PROJECT