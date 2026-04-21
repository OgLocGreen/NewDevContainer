 

## 1. Create an SSH Configuration File

  

The SSH configuration file helps you simplify the connection to remote servers. Follow these steps:

  

1. Open the SSH configuration file:

```bash

nano ~/.ssh/config

```

  

2. Add the following configuration (adjust the values as needed):

```plaintext

Host myserver

HostName hostname_or_ip

User username

IdentityFile ~/.ssh/id_rsa

Port 22

```

  

3. Save the file and exit the editor (`Ctrl+O`, `Enter`, `Ctrl+X`).

  

4. Test the configuration:

```bash

ssh myserver

```

  

---

  

## 2. Create an SSH Key Pair

  

If you don’t already have an SSH key pair, create one:

  

1. Generate the SSH key pair:

```bash

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

```

  

2. You will be prompted to:

- Specify a file location: Press `Enter` to use the default path (`~/.ssh/id_rsa`).

- Enter a passphrase (optional): Press `Enter` to skip.

  

3. Your private key will be saved as `~/.ssh/id_rsa`, and your public key as `~/.ssh/id_rsa.pub`.

  

---

  

## 3. Copy the Public Key to the Server

  

### Option 1: Using `ssh-copy-id`

1. Copy the public key to the server:

```bash

ssh-copy-id -i ~/.ssh/id_rsa.pub username@hostname

```

  

2. Test the connection:

```bash

ssh username@hostname

```

  

### Option 2: Manual Method

1. Display the public key:

```bash

cat ~/.ssh/id_rsa.pub

```

  

2. Copy the entire key (it starts with `ssh-rsa`).

  

3. Log in to the server:

```bash

ssh username@hostname

```

  

4. On the server, create or edit the file `~/.ssh/authorized_keys`:

```bash

mkdir -p ~/.ssh

chmod 700 ~/.ssh

nano ~/.ssh/authorized_keys

```

  

5. Paste the public key into the file and save it.

  

6. Set the correct permissions:

```bash

chmod 600 ~/.ssh/authorized_keys

```

  

7. Test the connection:

```bash

ssh username@hostname

```

  

---

  

## 4. Verify and Troubleshoot

  

- **Check File Permissions**:

```bash

chmod 700 ~/.ssh

chmod 600 ~/.ssh/id_rsa

chmod 644 ~/.ssh/id_rsa.pub

chmod 600 ~/.ssh/authorized_keys

```

  

- **Debugging**: Use the verbose mode for debugging:

```bash

ssh -vvv username@hostname

```

