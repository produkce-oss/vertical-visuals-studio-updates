# 2.4.1

## Fixes

- Long King’s Show and Brunato Talks recordings now skip an unnecessary first compression pass and encode directly to the Gemini-safe target size.
- Compression reports live output growth instead of appearing frozen at 95% with `0s left`.
- Active compression is no longer marked as stuck while the encoded file is still growing.

## Recovery

After updating, stop the old stalled run and choose **Resume → Keep video, redo upload & compress**. VVS keeps the downloaded source and restarts from the fixed compression step.
