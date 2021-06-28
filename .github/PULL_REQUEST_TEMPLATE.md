I changed to use ContiguousArray< UIViewController > type to store UIViewControllers in a contiguous block of memory.

 When using a large number of UIViewControllers as tabs, I think that using ContiguousArray will yield more predictable performance compared to Array.



The changed files are:

- Sources/PagerTabStripViewController.swift

for Example:

- BarExampleViewController.swift
- ButtonBarExampleViewController.swift
- InstagramExampleViewController.swift
- NavButtonBarExampleViewController.swift
- SegmentedExampleViewController.swift
- SpotifyExampleViewController.swift
- TwitterExampleViewController.swift
- YoutubeExampleViewController.swift
- YoutubeWithLabelExampleViewController.swift



References

- https://github.com/apple/swift/blob/main/docs/Arrays.rst

- https://developer.apple.com/documentation/swift/contiguousarray

- https://github.com/apple/swift/blob/main/docs/OptimizationTips.rst#advice-use-contiguousarray-with-reference-types-when-nsarray-bridging-is-unnecessary

- http://jordansmith.io/on-performant-arrays-in-swift/
- https://medium.com/@nitingeorge_39047/swift-array-vs-contiguousarray-a6153098a5