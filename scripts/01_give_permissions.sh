set -e
PROJECT_ID="secret-epsilon-474011-m4"
SERVICE_ACCOUNT="github-actions-deployer@$PROJECT_ID.iam.gserviceaccount.com"

#SERVICE_ACCOUNT="github-actions@$PROJECT_ID.iam.gserviceaccount.com"

# Si quieres acceso con permisos sudo (recomendado para despliegues)
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/compute.osLogin"

# Si quieres acceso con permisos sudo (recomendado para despliegues)
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/compute.osAdminLogin"
