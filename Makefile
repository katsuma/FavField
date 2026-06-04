APP         = FavField
SCHEME      = FavFieldWatch
TARGET      = FavFieldWatch
SDK         = watchsimulator26.2
VERSION    ?= $(shell /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" FavFieldWatch/Resources/Info.plist 2>/dev/null || echo "0.0.0")

.PHONY: build generate clean

generate:
	xcodegen generate

build: generate
	xcodebuild -project $(APP).xcodeproj -target $(TARGET) \
	  -sdk $(SDK) \
	  -configuration Debug \
	  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES \
	  ONLY_ACTIVE_ARCH=NO

clean:
	rm -rf DerivedData build
	@echo "Cleaned build artifacts."
