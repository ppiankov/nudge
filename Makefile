.DEFAULT_GOAL := help

APP_NAME = Nudge
BUNDLE_ID = com.ppiankov.nudge
BUILD_DIR = .build
RELEASE_DIR = build
APP_DIR = $(RELEASE_DIR)/$(APP_NAME).app

.PHONY: help build release test run lint fmt app dmg clean all

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build debug binary
	swift build

release: ## Build optimized binary
	swift build -c release

test: ## Run test suite
	swift test

run: build ## Build and run debug binary
	$(BUILD_DIR)/debug/Nudge

lint: ## Run SwiftLint
	swiftlint lint --strict

fmt: ## Run SwiftFormat (if installed)
	@which swiftformat > /dev/null 2>&1 && swiftformat Sources Tests || echo "swiftformat not installed, skipping"

app: release ## Create macOS .app bundle
	@mkdir -p "$(APP_DIR)/Contents/MacOS"
	@mkdir -p "$(APP_DIR)/Contents/Resources"
	@cp $(BUILD_DIR)/release/Nudge "$(APP_DIR)/Contents/MacOS/Nudge"
	@if [ -f Sources/Nudge/Resources/AppIcon.icns ]; then \
		cp Sources/Nudge/Resources/AppIcon.icns "$(APP_DIR)/Contents/Resources/AppIcon.icns"; \
	fi
	@/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $(BUNDLE_ID)" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@/usr/libexec/PlistBuddy -c "Add :CFBundleName string $(APP_NAME)" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string Nudge" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 0.1.0" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$(APP_DIR)/Contents/Info.plist" 2>/dev/null || true
	@echo "Built $(APP_DIR)"

dmg: app ## Create DMG installer
	@hdiutil create -volname "$(APP_NAME)" -srcfolder "$(RELEASE_DIR)" -ov -format UDZO "$(RELEASE_DIR)/$(APP_NAME).dmg" 2>/dev/null
	@echo "Built $(RELEASE_DIR)/$(APP_NAME).dmg"

clean: ## Remove build artifacts
	swift package clean
	rm -rf $(BUILD_DIR) $(RELEASE_DIR)

all: lint test release ## Full pipeline: lint, test, release build
