Steps to Update Pod
-------------------
For New Install Only:
pod repo update DoubleNodeSpecs

1. Check local files
pod lib lint --sources=git@github.com:DoubleNode/SpecsPrivateRepo.git,master --private

2. Create tag and push to github

3. Check repo file
pod spec lint --sources=git@github.com:DoubleNode/SpecsPrivateRepo.git,master --private

4. Final Submit
pod repo push DoubleNodeSpecs WKRSD_Cache_Worker.podspec


Steps to Resource Podfile Pods
------------------------------
When changing pod's "path" to/from development mode:

rm Pods/Manifest.lock && rm Podfile.lock && pod install
