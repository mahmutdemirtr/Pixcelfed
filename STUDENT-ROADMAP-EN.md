# STUDENT ROADMAP - PixelFed Docker Installation Project

## Project Description

You will install **PixelFed** (an Instagram-like open source social media platform) using Docker on AWS cloud platform.

**Goal:** PixelFed instance running at `http://SERVER-IP:8080`

**Deliverables:** Screenshots + report

---

## Requirements

- AWS account (student account is sufficient)
- Basic Linux knowledge
- Understanding of Docker concepts
- Ability to use SSH

---

## Steps Summary (10 Steps)

1. Create AWS EC2 instance
2. Connect via SSH
3. System update
4. Install Docker
5. Clone repository
6. Edit .env file
7. Start containers
8. **Run setup script** ← AUTOMATIC!
9. Create admin user
10. Web test

---

## Step 1: Create AWS EC2 Instance

### What Will You Do?

You will rent a Linux server on Amazon Web Services.

### Why?

To run the PixelFed web application, you need a server that's always on 24/7. When you turn off your own computer, the application stops, but an AWS server runs continuously.

### How?

**AWS Console → EC2 → Launch Instance**

**To Do:**
- Name: `pixelfed-server`
- AMI: Amazon Linux 2023
- Instance type: t2.medium (2 vCPU, 4 GB RAM)
- Create and download key pair (.pem file)
- Security Group: Open ports 22 (SSH) and 8080 (PixelFed)

### Success Criteria

- [ ] Instance is "Running"
- [ ] Public IP exists
- [ ] .pem file downloaded

---

## Step 2: SSH Connection

### What Will You Do?

You will connect to the server via terminal.

### Why?

You need terminal access to send commands to the server. There's no GUI, everything is command-line.

### How?

- Set permissions on .pem file (chmod 400)
- Connect with SSH command
- User: ec2-user

### Success Criteria

- [ ] SSH connection successful
- [ ] Prompt shows "ec2-user@ip"

---

## Step 3: System Update

### What Will You Do?

You will update packages on the server.

### Why?

For security patches and latest packages. Old packages can cause errors.

### How?

- Update system with yum update
- Install required tools like curl and git

### Success Criteria

- [ ] Package update completed
- [ ] curl and git installed

---

## Step 4: Docker Installation

### What Will You Do?

You will install Docker and Docker Compose.

### Why?

PixelFed consists of multiple services (web, database, redis, worker). With Docker, you run all of them as isolated containers.

### What is Docker?

Container technology that packages applications and their dependencies. Each container runs in its own world.

### What is Docker Compose?

A tool that manages multiple containers with a single command. Our project has 4+ containers.

### How?

- Install Docker with yum
- Start and enable Docker service
- Add user to docker group
- Download Docker Compose binary from GitHub

### Success Criteria

- [ ] docker --version works
- [ ] docker-compose --version works
- [ ] Docker service running

---

## Step 5: Clone Repository

### What Will You Do?

You will clone the GitHub repository prepared by your instructor.

### Why?

PixelFed installation files, docker-compose.yaml, and .env.docker template are ready in this repo. **Also includes automatic setup script!**

### Repository Address

```
https://github.com/mahmutdemirtr/Pixcelfed.git
```

### How?

- Run git clone in home directory
- Enter pixelfed folder
- Check files

### Should See

- compose.yaml (Docker services definition)
- .env.docker (environment template)
- **setup-pixelfed.sh** ← AUTOMATIC SETUP SCRIPT!
- KURULUM.md (detailed installation guide)

### Success Criteria

- [ ] Repo cloned
- [ ] compose.yaml and .env.docker present
- [ ] setup-pixelfed.sh present

---

## Step 6: Edit .env File

### What Will You Do?

You will edit environment variables.

### Why?

You need to tell PixelFed your server IP, database password, etc. Each installation uses different settings.

### What is .env?

Laravel framework's configuration file. Database, mail, cache settings are here.

### 5 Fields to Edit

**1. APP_NAME** (Line 10)
- Application name
- Example: "PixelFed"

**2. APP_DOMAIN** (Line 13)
- **ONLY** server IP (NO PORT!)
- Example: "54.221.128.45"
- **Where to find:** AWS Console → EC2 → Public IPv4
- **⚠️ CRITICAL:** Don't add `:8080`! Port only in APP_URL

**3. APP_URL** (Line 16)
- Full URL
- Example: "http://54.221.128.45:8080"
- **Note:** `http://` (not https!)

**4. INSTANCE_CONTACT_EMAIL** (Line 24)
- Contact email
- Example: "admin@pixelfed.local"

**5. DB_PASSWORD** (Line 30)
- Database password
- **Set a strong password!**
- Example: "PixelFed2025_Secure!"

### How to Edit?

- Copy .env.docker to .env
- Open with nano or vim
- Search with Ctrl+W and change
- Save with Ctrl+O

### Success Criteria

- [ ] .env file created
- [ ] 5 fields correctly filled
- [ ] NO PORT in APP_DOMAIN!
- [ ] Own IP address used

---

## Step 7: Start Containers

### What Will You Do?

You will start all services with Docker Compose.

### Why?

PixelFed isn't a single application, it's an orchestration of multiple services:
- **web:** Apache + PHP
- **worker:** Background jobs
- **db:** MariaDB database
- **redis:** Cache

### How?

- Start with docker-compose up -d command
- -d: detached mode (run in background)
- Wait 2-3 minutes (first startup is long)

### Status Check

Check with docker-compose ps.

**Should see:**
- pixelfed-web: Up
- pixelfed-worker: Up
- pixelfed-db: Up
- pixelfed-redis: Up

### Success Criteria

- [ ] All containers "Up"
- [ ] No error logs

---

## Step 8: Automated Setup Script ⚡

### What Will You Do?

You will run the ready-made setup script.

### Why?

There are 7 technical steps like migration, cache, key generation. Doing them manually is both difficult and error-prone. The script does everything automatically.

### What Does the Script Do? (Behind the Scenes)

The script automatically does:

1. **Migration:** Creates database tables (240+ tables)
2. **Key Generate:** Generates Laravel application key
3. **Storage Link:** Creates symlink for photos
4. **Cache:** Creates config, route, and view caches
5. **Instance Actor:** Creates instance actor for ActivityPub
6. **Package Discovery:** Discovers Laravel packages
7. **Horizon:** Installs queue monitoring tool
8. **Final Rebuild:** Final cache rebuild and container restart

### What is Migration?

Laravel's database schema versioning system. Migration files contain `CREATE TABLE` commands. PixelFed uses 240+ tables (users, posts, likes, followers, etc.).

### What is ActivityPub?

The protocol that platforms like Mastodon and PixelFed use to communicate with each other. Like email, you can message even if you're on different services.

### What is Horizon?

A dashboard that monitors Redis queue jobs. You can track background jobs.

### How to Run?

**Method 1: With Script (Easy)**
```bash
./setup-pixelfed.sh
```

**Method 2: Manual (If script fails)**
```bash
sudo docker-compose exec web php artisan migrate --force
sudo docker-compose exec web php artisan key:generate
sudo docker-compose exec web php artisan storage:link
sudo docker-compose exec web php artisan config:cache
sudo docker-compose exec web php artisan route:cache
sudo docker-compose exec web php artisan view:cache
sudo docker-compose exec web php artisan instance:actor
sudo docker-compose exec web php artisan package:discover
sudo docker-compose exec web php artisan horizon:install
sudo docker-compose exec web php artisan route:cache
sudo docker-compose restart web
sleep 3
```

### Expected Output

```
=========================================
PixelFed Setup Script Starting...
=========================================

[⏳] Checking container status...
[✓] Containers running

[⏳] Step 1/8: Running database migrations...
           (This step may take 1-2 minutes, please wait...)
[✓] Migration completed! (240+ tables created)

[⏳] Step 2/8: Generating Laravel application key...
[✓] Application key generated

[⏳] Step 3/8: Creating storage symlink...
[✓] Storage link created

[⏳] Step 4/8: Creating caches...
           → Config cache...
           → Route cache...
           → View cache...
[✓] All caches created (config, route, view)

[⏳] Step 5/8: Creating instance actor...
[✓] Instance actor created

[⏳] Step 6/8: Discovering Laravel packages...
[✓] Packages discovered

[⏳] Step 7/8: Installing Horizon...
[✓] Horizon installed

[⏳] Step 8/8: Final cache rebuild and container restart...
           → Rebuilding route cache...
           → Restarting web container...
           → Waiting for container to be ready...
[✓] Cache rebuild and restart completed

=========================================
✓ SETUP COMPLETED!
=========================================

Next steps:
1. Create admin user:
   sudo docker-compose exec web php artisan user:create

2. Open in browser:
   http://54.221.128.45:8080

Good luck! 🚀
```

### Duration

~2-3 minutes (migration is the longest step)

### Success Criteria

- [ ] Script ran without errors
- [ ] "✓ SETUP COMPLETED!" message appeared
- [ ] All 8 steps got "✓"
- [ ] No error messages

---

## Step 9: Create Admin User

### What Will You Do?

You will create the first user (admin).

### Why?

You need a user to log into PixelFed. The first user will be admin.

### How?

Single command:
```bash
sudo docker-compose exec web php artisan user:create
```

### What to Enter

The script will ask you in sequence:
```
Username: admin
Email: admin@pixelfed.local
Name: Admin User
Password: (strong password - invisible)
Confirm Password: (same password)
Make this user an admin? (yes/no): yes
Confirm user creation? (yes/no): yes
```

### Success Criteria

- [ ] User created
- [ ] "Created new user!" message appeared
- [ ] Admin privileges granted
- [ ] Password saved (don't forget!)

---

## Step 10: Web Test

### What Will You Do?

You will access PixelFed from your browser.

### How?

**Open in browser:**
```
http://<YOUR_IP>:8080
```

### Homepage Test

**Should see:**
- ✅ PixelFed logo
- ✅ "Login" button
- ✅ "Discover", "About" links
- ❌ NO 404 error!

### Login Test

- Click Login button
- Enter username and password
- Log in

**After login:**
- ✅ Timeline should load
- ✅ Left menu should show "Home", "Discover", "Groups"
- ✅ Should be able to upload profile photo

### Success Criteria

- [ ] Homepage opens (no 404!)
- [ ] Login successful
- [ ] Timeline displaying
- [ ] Can upload photos

---


## Deliverables

### 1. Screenshots

- [ ] EC2 instance in Running state
- [ ] docker-compose ps output (all containers Up)
- [ ] Script ran successfully ("✓ SETUP COMPLETED!")
- [ ] Homepage open in browser (URL visible)
- [ ] Timeline after login

### 2. Report (PDF)

**Content:**
- AWS region used
- EC2 Public IP
- Errors encountered and solutions
- **Explanation of what the script does** (8 steps)
- Explanation of what migration is
- Explanation of why Docker Compose is needed

---

## Grading

### ⭐ 60 Points - Basic Setup
- EC2 created
- Docker installed
- Repository cloned
- .env edited
- Containers running

### ⭐ 80 Points - Script Success
- **setup-pixelfed.sh ran successfully**
- Migration completed
- Admin user created

### ⭐ 100 Points - Working Application
- Web interface accessible
- Login successful
- Timeline loading
- **No 404 error!**

---

## Important Notes

### ⚠️ Most Common Mistake

**Adding port to APP_DOMAIN!**

❌ Wrong: `APP_DOMAIN="54.221.128.45:8080"`
✅ Correct: `APP_DOMAIN="54.221.128.45"`

Port should **only** be in APP_URL!

### 💡 Tips

1. Check after each step, then proceed
2. Read the log if script fails
3. Backup .env file
4. Don't forget admin password!
5. Script may take 2-3 minutes, be patient

### 📚 What You'll Learn

- AWS EC2 management
- Docker & Docker Compose
- **Automation (writing and using scripts)**
- Laravel framework (migration, cache, artisan)
- Database migration concept
- Linux command line
- Networking (ports, security groups)
- Troubleshooting skills

### 🎯 Script Advantages

- ✅ No manual error risk
- ✅ All steps automatic
- ✅ Consistent result
- ✅ Time savings
- ✅ Production-ready approach

**In the real world:** Deployment scripts work like this. DevOps engineers don't do manual installation, they automate everything!

---

## Good Luck! 🚀

By the end of this project:
- ✅ You'll be able to deploy a production-ready web application
- ✅ You'll be able to do Docker orchestration
- ✅ You'll be able to use automation scripts
- ✅ You'll be able to manage AWS EC2
- ✅ You'll have experienced DevOps operations

**PixelFed installation in 10 steps - Easy with the script!**
