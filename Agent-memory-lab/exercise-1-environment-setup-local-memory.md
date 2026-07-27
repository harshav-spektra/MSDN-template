# Exercise 1: Environment Setup & Local Memory

### Estimated Duration: 75 Minutes

## 📘 Scenario

Contoso Health Services is building AI agents that can remember users across conversations. Before developing full agent applications, the organization must prepare its development environment, connect it to the pre-provisioned **Azure OpenAI** resource, and validate the **Agent Memory** framework end to end using the basic memory notebook with a local **SQLite** backend.

In this lab, you will act as an AI Engineer responsible for verifying the tooling, configuring the environment variables, installing dependencies, running the basic memory demo notebook cell by cell, observing how the memory system behaves, and tuning its configuration parameters.

## 📖 Overview

In this exercise, you will verify the required tools and open the project, retrieve the Azure OpenAI endpoint and API key from the pre-created resource and configure them in the `.env` file, then install the project dependencies.

You will then open the `01_basic_memory.ipynb` notebook in Visual Studio Code, select the correct Python kernel, and execute each cell while understanding what it does — from initializing `AgentMemory` with buffer management, through an 8-turn conversation that triggers automatic summarization, to cross-session recall and semantic search. Finally, you will tune the memory configuration parameters and re-run the notebook to observe how behavior changes.

## 🎯 Objectives

In this exercise, you will perform:

- Task 1: Verify Tools and Open the Project
- Task 2: Review Environment Configuration
- Task 3: Install Dependencies & Run Basic Demo
- Task 4: Observe Memory Behavior
- Task 5: Explore Memory Configuration Tuning (Optional)

## Task 1: Verify Tools and Open the Project

In this task, you will confirm that Python, uv, and Git are installed at the required versions, open the project in Visual Studio Code, and inspect the repository structure.

1. On the **Desktop** of your **Lab VM**, launch **Visual Studio Code**.

   ![](./Images/ETS111.png)

1. Once the IDE opens, if you see the ***Welcome to VS Code*** sign-in pop-up for GitHub, simply close the window by clicking the **X** in the upper-right corner.

   ![](./Images/ETS112.png)

1. Go to **File (1)** and click **Open Folder... (2)**.

   ![](./Images/ETS113.png)

1. Navigate to `C:\LabFiles` **(1)**, select the **azure-ai-agents-labs (2)** folder and then click **Select Folder (3)**.

   ![](./Images/ETS114.png)

1. If there is a notification that it is in **Restricted mode**, click on **Manage**. 

   ![](./Images/ETS115.png)

1. You will see a **Workspace Trust** wizard click on **Trust (1)** and close the wizard by clicking on **X (2)**.

   ![](./Images/ETS116.png)

1. Click on the **ellipsis (...) (1)** in the top menu, then select **Terminal (2)** and click **New Terminal (3)**.

   ![](./Images/ETS117.png)

1. In the Explorer pane, confirm the following top-level folders are present: **demo/**, **memory/**, **server/**, **tests/**.

   ![](./Images/ETS118.png)

1. Open **demo/README.md** and take a moment to review the demo matrix table — it maps each numbered demo script/notebook to the feature it showcases.

   ![](./Images/ETS119.png)

1. Click on the **ellipsis (...) (1)** in the top menu, then select **Terminal (2)** and click **New Terminal (3)**.

   ![](./Images/ETS117.png)

1. Verify the required tooling versions by running the following commands one by one:

   ```
   python --version
   uv --version
   git --version
   ```

   ![](./Images/ETS1110.png)

   > **Note:** Python must be **3.12 or later** — the `sqlite-vec` extension used by the local SQLite backend requires it.

## Task 2: Review Environment Configuration

In this task, you will navigate to the pre-created Azure OpenAI resource, open it in the Foundry portal, copy the endpoint and API key, and paste them into the project's `.env` file.

> **Note:** The Azure OpenAI resource and its model deployments have already been created in this lab environment — you do not need to create any new resources.

1. On the **Microsoft Edge** browser,go to **Azure portal**. In the search bar at the top, search for **Azure OpenAI (1)**, and select **Azure OpenAI (2)** from the **Services** section.

   ![](./Images/ETS1111.png)

1. Select the **openai-<inject key="Deployment ID" enableCopy="false"></inject>**

   ![](./Images/ETS1112.png)

1. On the resource **Overview** pane, click on **Go to Foundry portal** (or **Explore Azure AI Foundry portal**) to open the resource in the Foundry portal.

1. In the Foundry portal, from the left navigation pane, select **Deployments**, and verify the required model deployments are listed (a chat model and an embedding model).

1. Navigate to the **Overview** (or **Home**) page of your project, and locate the **Endpoint and keys** section.

1. Copy the **Azure OpenAI endpoint (1)** — it looks like the following — and paste it into Notepad for later use:

   ```
   https://<your-resource-name>.openai.azure.com/
   ```

1. Copy the **API Key (2)** and paste it into Notepad for later use.

   > **Note:** Ensure you copy the **Azure OpenAI** endpoint (ending in `openai.azure.com`), not the generic project endpoint — the notebook's client requires the Azure OpenAI format.

1. Return to Visual Studio Code. In the Explorer pane, select and right click on .`env.example` **(1)** and select **Rename (2)**.

   ![](./Images/ETS122.png)

1. Rename the file to `.env` and click on it to open the file.

   ![](./Images/ETS123.png)

1. In the `.env` file, provide the following environment variables using the values you copied to Notepad:

   - **AZURE_OPENAI_ENDPOINT**: Repalce the endpoint value you copied in Step 6.
   - **AZURE_OPENAI_API_KEY**: Replace the API key you copied in Step 7.

   ![](./Images/ETS121.png)

1. Save the changes made to the `.env` file by pressing **CTRL + S**.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Scroll down in the lab guide and hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
> - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help you out.

## Task 3: Install Dependencies & Run Basic Demo

In this task, you will install the project dependencies, open the `01_basic_memory.ipynb` notebook, select the correct kernel, and execute the setup, initialization, and Session 1 cells while understanding exactly what each one does.

1. In the Visual Studio Code **terminal**, run the below command from the project root to install all dependencies:

   ```
   uv sync --extra dev
   ```

   ![](./Images/ETS131.png)

   > **Note:** This can take 5–10 minutes to complete. Wait for the command execution to complete, then proceed ahead.

1. In the Explorer pane, navigate to the **demo** folder, expand **notebooks (1)** and open the **01_basic_memory.ipynb (2)** file.

   ![](./Images/ETS133.png)

1. Take a moment to read the first markdown cell, **"01 Basic Agent Memory Demo"**. It outlines what you will learn: manual `add_turn()`, context retrieval, automatic buffer management, cross-session memory, and semantic search — and notes that the demo uses **SQLite** for zero-configuration setup.

   ![](./Images/ETS132.png)

1. Click **Select Kernel (1)** in the top-right corner and choose **Install/Enable suggested extensions Python + Jupyter (2)** if prompted.

   ![](./Images/ETS134.png)

1. Wait for the Python extension to be installed.

   > **Note:** This can take 5–10 minutes to complete. Wait for the command execution to complete, then proceed ahead.

1. Once the Python extension is installed, click on **Select Kernel (1)** then select **Python Environments (2)** 

   ![](./Images/ETS135.png)

1. Select the project's virtual environment, **agent-memory(3.14.6)(Python 3.14.6)** from the list to ensure that the Jupyter Notebook runs in the correct Python interpreter with the necessary dependencies installed.

   ![](./Images/ETS136.png)

1. Run the first code cell under **Step 1: Setup and Configuration**. This cell prepares everything the demo needs before any AI calls are made:

   ![](./Images/ETS137.png)

   - **Imports libraries** (`asyncio`, `os`, `sys`, `pathlib`) and attempts to load `python-dotenv` — if dotenv is missing, it warns but continues.
   - **Finds the project root** by walking up the directory tree looking for `pyproject.toml`, then adds it to `sys.path` so the `memory` package can be imported.
   - **Loads your `.env` file** — this is where the endpoint and key you configured in Task 1.2 are read into the environment.
   - **Defines the demo identifiers**: `USER_ID = "basic_demo_user"` and the SQLite database path `demo_basic_notebook.db`.
   - **Deletes any previous demo database** so every run starts from a clean state (retrying up to 5 times if the file is locked).

   You should see the output ending with: ✅ Step 1 Complete: All imports and paths configured!

      ![](./Images/ETS138.png)

1. Run the next code cell under **Step 2: Initialize AgentMemory**. This cell creates the memory system itself:

   ![](./Images/ETS139.png)

   - **Imports the key classes**: `AzureOpenAI` from the OpenAI SDK, and `AgentMemory` + `AgentMemoryConfig` from the `memory` package.
   - **Validates environment variables** — it checks that `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_API_KEY` are set. If either is missing, the cell prints which one and skips initialization; if this happens, re-check your `.env` from Task 1.2, save it, and restart the kernel.
   - **Creates the Azure OpenAI client** using your endpoint, key, and API version.
   - **Explains the buffer management concept** — long conversations can't all be sent to the LLM (context limits), so AgentMemory prunes automatically: when the buffer reaches `buffer_size` turns, older turns are compressed into a summary while the most recent `active_turns` stay verbatim.
   - **Creates the configuration**: `buffer_size=6` (prune when the buffer hits 6 turns), `active_turns=4` (keep the last 4 turns verbatim), and `longterm_synthesis_frequency=1` (extract insights after every session).
   - **Initializes AgentMemory** with the user ID, OpenAI client, SQLite path, and the config.

   You should see: `✅ AgentMemory initialized and ready!`

      ![](./Images/ETS1310.png)

1. Run the next code cell under **Step 3: Session 1 — Multi-Turn Conversation with Buffer Pruning**. This is the main demonstration:

      ![](./Images/ETS1312.png)

   - **Defines a realistic 8-turn conversation** as a hardcoded list of (user, assistant) message pairs — a book-recommendation dialogue covering science fiction, philosophy, novel length preference, and reading habits. You do not type anything; the conversation is pre-scripted in the cell.
   - **Starts Session 1** with `memory.start_session()` and prints the session ID and buffer configuration.
   - **Stores each turn** by looping through the conversation and calling `await memory.add_turn(user_msg, assistant_msg)` — this is the core storage API.
   - **Triggers automatic pruning**: because the conversation has 8 turns and `buffer_size=6`, the buffer fills mid-conversation and older turns are automatically summarized while the last 4 remain verbatim.
   - **Prints the buffer management result**: the final formatted context from `await memory.get_context()`, its size in characters, and a preview — look for a summary block representing turns 1–4 followed by the recent verbatim turns.
   - **Ends the session automatically** when the `async with memory:` context manager exits.

      ![](./Images/ETS1313.png)

      >**Note**: To see the full output fo the cell, click on `Scrollable element` .

      ![](./Images/ETS1314.png)

## Task 4: Observe Memory Behavior

In this task, you will execute the cross-session recall and semantic search cells, then inspect the demo output and the SQLite database to understand how active turns are managed, when summarization triggers, and how a new session recalls facts from the previous one.

1. Run the next code cell under **Step 4: Cross-Session Memory Recall**. This proves persistence across sessions:

      ![](./Images/ETS1315.png)

   - **Starts a brand-new session** (a different session ID from Session 1) for the same user.
   - **Retrieves context immediately** with `await memory.get_context()` — before any new turns are added.
   - **Shows that the context is not empty**: it prints the loaded context size and a 700-character preview containing content from Session 1.
   - **Prints the key insight**: even in a new session, memory automatically includes (1) previous session summaries, (2) extracted insights and facts, and (3) semantic embeddings of past conversations.

   Verify in the preview that details from the book conversation (Session 1) are present even though this session has stored nothing yet.

      ![](./Images/ETS1316.png)

1. Run the final code cell under **Step 5: Semantic Search Demonstration**. This shows retrieval by meaning rather than keywords:

      ![](./Images/ETS1317.png)

   - **Defines three search queries**: `"science fiction book recommendations"`, `"philosophy and consciousness"`, and `"reading habits and preferences"`.
   - **Searches memory** for each query using `await memory.search(query, top_k=2, search_interactions=True, search_insights=True)` — searching across both raw interactions and extracted insights.
   - **Prints a preview of the results** for each query. Notice that matches are found by semantic similarity — the stored turns never used the exact phrase "reading habits", yet the bedtime-reading turn is retrieved.
   - **Prints the final summary** of everything demonstrated: `add_turn()` for storage, `get_context()` for prompt-ready memory, automatic buffer management, cross-session persistence, and semantic search — all with **no Agent Framework required**.

   You should see the output ending with: `🎉 NOTEBOOK COMPLETE!`

      ![](./Images/ETS1318.png)

1. In the Explorer pane, confirm the **demo_basic_notebook.db** file now exists in the project root — this is the SQLite database holding everything the notebook stored.

1. (Optional) Open the database in a terminal to inspect the raw records and identify where verbatim turns end and summarized content begins:

   ```
   sqlite3 demo_basic_notebook.db
   .tables
   ```

## Task 5: Explore Memory Configuration Tuning (Optional)

In this task, you will adjust the key memory configuration parameters in the notebook and re-run it to observe how behavior changes with different settings.

1. In the notebook, scroll to the **Step 2: Initialize AgentMemory** code cell and locate the **AgentMemoryConfig** block:

   ```
   config = AgentMemoryConfig(
       buffer_size=6,
       active_turns=4,
       longterm_synthesis_frequency=1,
   )
   ```
      ![](./Images/ETS1319.png)


1. Change **buffer_size** to a lower value, such as `3`, and **active_turns** to `2`.

1. Restart the kernel by clicking **Restart** in the notebook toolbar and then **Run all** to execute all the cells from the top

   > **Note:** Restarting is required — the memory object and configuration are created at cell execution time, so edits do not take effect on an already-running kernel state.

      ![](./Images/ETS1320.png)

1. Observe in the **Step 3** output how **summarization triggers earlier** than in the previous run — the buffer now fills after only 3 turns, so pruning happens much sooner in the 8-turn conversation, and only the last 2 turns remain verbatim.

1. Next, experiment with **longterm_synthesis_frequency** — this controls how often insights are extracted at session end. Re-run and note the effect on the insight generation messages in the output.

1. After observing the differences, revert all values to their defaults (`buffer_size=6`, `active_turns=4`, `longterm_synthesis_frequency=1`), restart the kernel, and re-run the notebook once more to leave the environment in a clean state.

   > **Note:** These same parameters appear again as production tuning knobs in a later exercise, so keep a note of what each one controls.

## 🧾 Summary

In this exercise, you accomplished the following:

- Verified the required tool versions (Python 3.12+, uv, Git) and explored the project structure
- Retrieved the Azure OpenAI endpoint and API key from the pre-created resource via the Foundry portal and configured them in the `.env` file
- Installed the project dependencies using `uv sync --extra dev`
- Opened the `01_basic_memory.ipynb` notebook, selected the correct Python kernel, and executed the setup, initialization, and Session 1 cells
- Observed automatic buffer pruning during an 8-turn conversation, validated cross-session memory recall, and performed semantic searches across stored interactions and insights
- Inspected the SQLite database created by the demo
- Tuned the `buffer_size`, `active_turns`, and `longterm_synthesis_frequency` configuration parameters and observed how each affects summarization and insight generation

You have successfully completed this exercise. Click **Next >>** to continue to the next exercise.
