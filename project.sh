echo "Select one of the following option to execute appropriate tasks"
echo "1 - First time project loading"
echo "2 - Switched working branches"
echo "3 - Clear build data"
echo "4 - Run build watcher"
echo "5 - Android app"
echo "6 - IOS app"
read "choice"

cleanBuild() {
  flutter clean
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
}

runBuildWatcher() {
  flutter pub run build_runner watch --delete-conflicting-outputs
}

if [ -z "$choice" ];then
    echo "choice cannot be null"
    exit 1
fi
if [ "$choice" == 1 ] || [ "$choice" == 2 ]|| [ "$choice" == 3 ];then
    cleanBuild
elif [ "$choice" == 4 ];then
    runBuildWatcher
elif [ "$choice" == 5 ];then
    source scripts/android.sh
elif [ "$choice" == 6 ];then
    source scripts/ios.sh
else
    echo "Invalid choice"
    exit 1
fi