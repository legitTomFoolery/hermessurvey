# Environment Configuration System

This system provides a centralized way to toggle between development and production environments for Firestore collection references throughout the application.

## Overview

The environment configuration system allows you to easily switch between:

- **Development Mode**: Collection names are prefixed with 'dev-' (e.g., 'dev-questions')
- **Production Mode**: Collection names have no prefix (e.g., 'questions')

This is particularly useful when you need to work with separate development and production databases without changing collection references throughout your code.

## How It Works

The system consists of:

1. **Dart Configuration** (`environment_config.dart`): Manages environment settings for Flutter code
2. **Python Configuration** (`scripts/environment_config.py`): Manages environment settings for Python scripts
3. **Toggle Utility** (`scripts/toggle_environment.py`): A script to easily switch between environments

## Usage

### In Flutter Code

The environment is automatically applied to all Firestore collection references that use the `EnvironmentConfig` class:

```dart
// Import the environment config
import 'package:gsecsurvey/core/environment_config.dart';

// Get an instance of the environment config
final envConfig = EnvironmentConfig();

// Use it to get the correct collection name
FirebaseFirestore.instance.collection(envConfig.getCollectionName('collectionName'))
```

### In Python Scripts

Python scripts can use the environment configuration by importing it:

```python
# Import environment configuration
try:
    # Try to import from set_environment.py (created by toggle_environment.py)
    from set_environment import env_config
except ImportError:
    # If set_environment.py doesn't exist, create a new instance
    from environment_config import EnvironmentConfig
    env_config = EnvironmentConfig()

# Use it to get the correct collection name
db.collection(env_config.get_collection_name('collectionName'))
```

### Toggling Between Environments

To switch between development and production environments, use the toggle script:

```bash
# Navigate to the scripts directory
cd scripts

# Switch to development mode (with 'dev-' prefix)
python toggle_environment.py dev

# Switch to production mode (without prefix)
python toggle_environment.py prod

# Toggle between modes (no argument)
python toggle_environment.py
```

## Files

- `lib/core/environment_config.dart`: Dart implementation of the environment configuration
- `scripts/environment_config.py`: Python implementation of the environment configuration
- `scripts/toggle_environment.py`: Utility script to toggle between environments
- `scripts/set_environment.py`: Generated file that sets the environment for Python scripts

## Implementation Details

The system uses a singleton pattern to ensure consistent environment settings throughout the application. When in development mode, collection names are prefixed with 'dev-'. When in production mode, the prefix is removed.

The toggle script updates both the Dart and Python configurations to ensure consistency across the entire application.
