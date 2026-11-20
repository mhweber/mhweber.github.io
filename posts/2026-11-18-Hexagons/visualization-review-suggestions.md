# Visualization review suggestions

Review of the [rendered Hexagons page](https://mhweber.github.io/posts/2026-11-18-Hexagons/Index.html), its notebook, and its map data.

## Recommendation

Keep the map as a companion for explaining how modeled river flow changed during this specific event. It adds regional coverage and an animated event narrative, but should not be presented as a replacement for observed gauge data, historical streamflow percentiles, or operational flood products.

## Highest-priority interpretation fixes

1. **Name the measure precisely.** Describe it as modeled streamflow change relative to the first timestamp. A single-event ratio is not a historical anomaly, flood probability, flood extent, or flood-severity measure.
2. **Use a true baseline ratio.** Divide each reach's flow by that reach's actual starting flow. If low baselines need to be excluded, state the threshold; cap only the map's display and retain the uncapped values for inspection.
3. **Explain what each cell represents.** Each hexagon displays one selected modeled river reach, not an area-wide or basin-wide flow summary. Expose its reach ID and current/baseline discharge so people can inspect the representative data.
4. **Protect the time axis.** Require every expected timestamp before exporting an equally spaced animation. If snapshots are missing, stop with an explicit error or show their actual elapsed intervals.
5. **Treat jump filtering as a quality flag.** Large step-to-step changes may reflect regulation, model behavior, or real events. Flag them for review instead of silently treating them as bad data.
6. **Keep the model caveat on the map.** Clearly say that the values are modeled, not observed, and are not flood severity.

## Map usability improvements

- Offer a flat 2D mode alongside the 3D storytelling view; tall extrusions can hide neighboring cells and make comparisons harder.
- Add click inspection with representative reach ID, current and baseline flow, uncapped ratio, and a small hydrograph.
- Replace the interpolated legend with labeled, clearly spaced values that match the actual color scale; make the neutral 1× reference obvious.
- Keep the metric explanation and NOAA attribution visible at narrow widths.
- Add slower playback or playback-speed controls; the current short frame delay makes detailed inspection difficult.

## Scientific context and comparisons

- For “how unusual is this flow for this river and season?”, compare against an appropriate historical-percentile distribution. A baseline-relative event ratio answers a different question.
- For observed conditions and station hydrographs, direct readers to the [USGS National Water Dashboard](https://dashboard.waterdata.usgs.gov/app/nwd/en/) or [Water Data for the Nation](https://waterdata.usgs.gov/).
- For operational forecasts and flood-related information, direct readers to NOAA's [National Water Prediction Service](https://www.weather.gov/owp/operations).
- Present gauge comparisons as approximate spot checks unless the reach matching, timestamps, and observations have been independently validated.

## Applied in `Index.ipynb`

- Renamed the presentation to modeled streamflow change and clarified that it is not an anomaly or flood-severity map.
- Removed the denominator floor from the ratio, retained the existing baseline eligibility threshold, and separated the uncapped ratio from the capped display values.
- Added an explicit failure when expected snapshots are missing, so skipped files cannot silently shift the baseline or animation timeline.
- Excluded reaches without complete time series, kept repeated-jump detections as review flags, and added the selected reach ID plus model/metric metadata to the export.
- Retained uncapped ratios rounded to three decimal places, while keeping the capped `surge` series for the existing animation.
- Updated the caveats to explain representative-reach semantics, baseline filtering, model limitations, and the display cap.

## Still to do in the rendered map

The notebook changes do not modify `map.html` or regenerate the published data. The map should next expose the new reach-level fields and uncapped ratios, add a 2D option and clearer legend, and keep the model/metric explanation visible on mobile. Rerun the data workflow and render/publish the page only after reviewing the newly generated data.
