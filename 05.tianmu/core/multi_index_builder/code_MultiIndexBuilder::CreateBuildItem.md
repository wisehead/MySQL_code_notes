#1.MultiIndexBuilder::CreateBuildItem

```
MultiIndexBuilder::CreateBuildItem
--if (!build_item) {
----build_item = std::make_shared<MultiIndexBuilder::BuildItem>(this);
----build_item->Initialize(initial_size_);
```