# InceptionOfThing


# Explication de la Partie 1 (p1)
La partie 1 de ce projet "Inception of Things" met en place un cluster Kubernetes K3s composé de deux machines virtuelles : un serveur (master) et un worker (agent). Voici comment cela fonctionne :
## Architecture
Le projet crée deux VMs Debian avec Vagrant/VirtualBox :
pjayS (Server/Master) - IP: 192.168.56.110
pjaySW (Server Worker) - IP: 192.168.56.111

Configuration des VMs (Vagrantfile:14-45)
Chaque VM dispose de :
- 1 CPU
- 1024 Mo de RAM
- Debian Bookworm 64 bits
- Un réseau privé pour communiquer entre elles
## Fonctionnement
### 1. Machine "pjayS" - Server (scripts/server.sh)
Le script server.sh:1-9 s'exécute automatiquement et :
Installe les outils nécessaires (net-tools, curl)
Installe K3s en mode serveur avec des paramètres spécifiques :
- --write-kubeconfig-mode=644 : rend le fichier kubeconfig accessible

- --tls-san pjaySW : ajoute le nom du worker aux certificats TLS
- --node-ip, --bind-address, --advertise-address : configure K3s pour écouter sur l'IP privée

Crée un alias k pour kubectl

Extrait le token d'authentification dans token.env (partagé entre les VMs via /vagrant/)
### 2. Machine "pjaySW" - Worker (scripts/worker.sh)
Le script worker.sh:1-7 :
Installe les mêmes outils
Installe K3s en mode agent qui :
Se connecte au serveur via https://192.168.56.110:6443
S'authentifie avec le token partagé depuis token.env
Utilise l'IP 192.168.56.111 comme node-ip

### À quoi ça sert ?

Cette partie 1 crée un cluster Kubernetes léger et fonctionnel pour :
- Apprendre les bases de l'orchestration Kubernetes
- Avoir une architecture multi-nœuds (master + worker) similaire à un environnement de production
- Tester le déploiement d'applications conteneurisées
- Comprendre comment les nodes communiquent dans un cluster K8s

Le token dans token.env permet l'authentification sécurisée du worker auprès du master, établissant ainsi un cluster où le master orchestre les pods et le worker exécute les charges de travail.

---

# Explication de la Partie 3 (p3)

La **partie 3** met en place une infrastructure de **déploiement continu (GitOps)** avec **K3d** (K3s dans Docker) et **ArgoCD**.

## Architecture p3

Cette partie utilise une **machine virtuelle Vagrant** qui contient :

- **K3d** : Cluster Kubernetes léger qui tourne dans Docker
- **ArgoCD** : Outil de déploiement continu GitOps
- **2 namespaces** : `argocd` et `dev`

La VM est configurée avec :

- 4 Go de RAM
- 2 CPUs
- Debian Bookworm 64 bits
- Port forwarding automatique vers l'hôte (8080 pour ArgoCD, 8888 pour l'application)

## Fichiers et leur rôle

### 1. scripts/install.sh

Script d'installation des dépendances :


- Installe **k3d** si absent
- Installe **kubectl** (client Kubernetes)
- Installe **Docker** et le configure
- Ajoute l'utilisateur au groupe docker

### 2. scripts/run.sh
Script principal qui orchestre tout le déploiement :

**Étape 1 (lignes 1-6)** : Installation et création du cluster
- Lance l'installation des dépendances
- Supprime et recrée un cluster k3d nommé "mycluster"

**Étape 2 (lignes 8-12)** : Création des namespaces
- `argocd` : pour ArgoCD
- `dev` : pour l'application

**Étape 3 (lignes 15-19)** : Déploiement d'ArgoCD
- Installe ArgoCD depuis les manifests officiels
- Attend que tous les pods soient prêts

**Étape 4 (lignes 21-27)** : Préparation et configuration
- Pull des images Docker (v1 et v2)
- Applique la configuration ArgoCD depuis config.yml

**Étape 5 (lignes 29-31)** : Récupération du mot de passe admin
- Extrait le mot de passe initial d'ArgoCD

**Étape 6 (lignes 33-40)** : Port forwarding
- Expose ArgoCD UI sur `localhost:8080`
- Expose l'application sur `localhost:8888`

### 3. confs/config.yml
Définit une **Application ArgoCD** :
- **Nom** : `will42`
- **Source** : Repository GitHub `InceptionOfThing` (branch `main`, path `p3/confs`)
- **Destination** : namespace `dev`
- **Synchronisation automatique** activée avec :
  - `prune: true` : supprime les ressources obsolètes
  - `selfHeal: true` : corrige automatiquement les dérives

### 4. confs/deployment.yaml
Manifests Kubernetes pour l'application :
- **Deployment** : 1 replica de `wil42/playground:v2` sur le port 8888
- **Service** : Expose le pod en interne

### 5. scripts/clean.sh
Script de nettoyage :
- Arrête et supprime les conteneurs Docker
- Supprime le cluster k3d
- Tue les processus de port forwarding

## Fonctionnement GitOps

1. ArgoCD surveille le repository GitHub (`https://github.com/Pierrickjay/InceptionOfThing`)
2. Il synchronise automatiquement le dossier `p3/confs` avec le cluster
3. Si vous modifiez `deployment.yaml` dans GitHub (ex: changer `v2` en `v1`), ArgoCD détecte le changement et met à jour automatiquement l'application
4. Le `selfHeal` garantit que si quelqu'un modifie manuellement le cluster, ArgoCD restaure l'état défini dans Git

## À quoi ça sert ?

Cette partie 3 démontre :
- Le principe **GitOps** : Git est la source de vérité unique
- Le **déploiement continu automatisé** sans intervention manuelle
- L'utilisation d'**ArgoCD** pour la gestion d'applications Kubernetes
- Un workflow moderne de DevOps/SRE

## Accès aux interfaces

Après avoir lancé `./scripts/run.sh` :
- **ArgoCD UI** : https://localhost:8080 (login: `admin`, password affiché dans le terminal)
- **Application** : http://localhost:8888
