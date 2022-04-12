# Type a script or drag a script file from your workspace to insert its path.
CD_PROVIDERS_DIR="$PROJECT_TEMP_DIR/../PassepartoutCore.build/Debug-iphonesimulator/PassepartoutProviders.build/DerivedSources/CoreDataGenerated/Providers"
CD_CORE_DIR="$PROJECT_TEMP_DIR/../PassepartoutCore.build/Debug-iphonesimulator/PassepartoutCore.build/DerivedSources/CoreDataGenerated/Core"
if [ -d "$CD_PROVIDERS_DIR" ]; then
    cp "$CD_PROVIDERS_DIR"/* "$PROJECT_DIR/PassepartoutCore/Sources/PassepartoutProviders/DataModels"
fi
if [ -d "$CD_CORE_DIR" ]; then
    cp "$CD_CORE_DIR"/* "$PROJECT_DIR/PassepartoutCore/Sources/PassepartoutCore/DataModels"
fi
