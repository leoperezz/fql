#!/bin/bash

# --- CONFIGURATION ---
# Define environments to test (Selection from OGBench)
ENVS=(
    "antmaze-large-navigate-singletask-v0"
    "cube-single-play-singletask-v0"
    "cube-double-play-singletask-v0"
    "scene-play-singletask-v0"
)

# Define agents to compare
# Format: "agent_path:agent_name"
AGENTS=(
    "agents/fdql.py:fdql"
    "agents/fql.py:fql"
    "agents/iql.py:iql"
)

# Define the range of alphas to sweep
# As recommended in the README for new environments
ALPHAS=(0.1 1.0 10.0 100.0)

STEPS=1000000 
GROUP="FDQL_Alpha_Sweep"

# --- EXECUTION ---
for ENV in "${ENVS[@]}"; do
    echo "##########################################################"
    echo "ENVIRONMENT: $ENV"
    echo "##########################################################"

    for AGENT_DATA in "${AGENTS[@]}"; do
        # Split the agent string into path and name
        IFS=":" read -r AGENT_PATH AGENT_NAME <<< "$AGENT_DATA"
        
        for ALPHA in "${ALPHAS[@]}"; do
            echo ">> Starting: Agent=$AGENT_NAME | Alpha=$ALPHA | Env=$ENV"
            
            # Executing the training
            # Using normalize_q_loss=True to ensure alpha scale is consistent
            python main.py \
                --env_name="$ENV" \
                --agent="$AGENT_PATH" \
                --agent.alpha="$ALPHA" \
                --agent.normalize_q_loss=True \
                --run_group="$GROUP" \
                --offline_steps="$STEPS" \
                --eval_interval=100000 \
                --log_interval=10000 \
                --seed=0

            echo "Done: $AGENT_NAME with Alpha=$ALPHA on $ENV"
            echo "----------------------------------------------------------"
        done
    done
done

echo "Full alpha sweep complete!"
