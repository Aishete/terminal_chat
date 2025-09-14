# Terminal_Chat
a simple api call in bash script just for sake of ask question in terminal. 

# Try Terminal_Chat
clone the repo to Try

  ```bash
  git clone git@github.com:Aishete/terminal_chat.git
  ```

then ask it will ask you to add token and just following it 

  ```bash
  sh ai.sh hey hello 
  ```

# how to only call ai to ask
This method creates an alias, which is a shortcut within your shell.

**make sure you make it execute able first**

  ```bash
  chmod +x ai.sh
  ```

1. **Open your shell's configuration file:** This is usually `.bashrc` (Bash), `.zshrc` (Zsh), or a similar file.

2. **Add an alias:** Add the following line to the file, replacing `/path/to/ai.sh` with the actual path:

   ```bash
   alias ai="/path/to/ai.sh"
   ```

3. **Source the configuration file:** Save the file and then source it to apply the changes:  
```bash

  ```
  ```bash
  source ~/.bashrc 
  ```

Now, typing `ai` will execute `ai.sh`, but only within the shell session where you defined the alias.

## TODO

- [x] use bash for the sake of learning
- [x] able to add and use api key to interact with ai in clould
- [ ] able to interact with terminal such as create file etc
- [ ] able store some ref memory 
- [ ] able to use local ai model as a brain

