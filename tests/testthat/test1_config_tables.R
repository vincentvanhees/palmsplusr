library(palmsplusr)
library(readr)

test_that("Testing config table workflow", {
  palms <- read_palms(system.file("extdata", "one_participant.csv", package = "palmsplusr"))
  participant_basis <- read_csv(system.file("extdata", "participant_basis.csv", package = "palmsplusr"))
  class_timetable <- read_csv(system.file("extdata", "class_timetable.csv", package = "palmsplusr"))

  home <- read_sf(system.file("extdata/shapefiles/", "home.shp", package = "palmsplusr"))
  home.buffer <- palms_buffer(point = home, distance = 100, crs = 2193)
  school <- read_sf(system.file("extdata/shapefiles/", "school.shp", package = "palmsplusr"))


  context("Testing data import")

  expect_is(palms, class = c("sf", "tbl_df", "tbl", "data.frame"))
  expect_is(school, class = c("sf", "tbl_df", "tbl", "data.frame"))
  expect_is(home.buffer, class = c("sf", "tbl_df", "tbl", "data.frame"))

  palms_add_field("duration",   "1", TRUE)

  palms_remove_tables()

  palms_add_field("weekday",    "dow < 6")
  palms_add_field("weekend",    "dow > 5")
  palms_add_field("indoors",    "iov == 3")
  palms_add_field("outdoors",   "iov == 1")
  palms_add_field("in_vehicle", "iov == 2")
  palms_add_field("inserted",   "fixtypecode == 6")
  palms_add_field("pedestrian", "tripmot == 1")
  palms_add_field("bicycle",    "tripmot == 2")
  palms_add_field("vehicle",    "tripmot == 3")
  palms_add_field("nonwear",    "activityintensity < 0",  TRUE)
  palms_add_field("wear",       "activityintensity >= 0", TRUE)
  palms_add_field("sedentary",  "activityintensity == 0", TRUE)
  palms_add_field("light",      "activityintensity == 1", TRUE)
  palms_add_field("moderate",   "activityintensity == 2", TRUE)
  palms_add_field("vigorous",   "activityintensity == 3", TRUE)
  palms_add_field("mvpa",       "activityintensity > 1",  TRUE)

  palms_add_field("at_home", "palms_in_polygon(., filter(home.buffer, identifier == i), identifier)")
  palms_add_field("at_school", "palms_in_polygon(., filter(school, school_id == participant_basis %>% filter(identifier == i) %>% pull(school_id)))")


  palms_add_domain("home", "at_home")
  palms_add_domain("school", "(!at_home & at_school)")
  palms_add_domain("transport", "!at_home & !(at_school) & (pedestrian | bicycle | vehicle)")
  palms_add_domain("leisure", "!at_home & !(at_school) & !pedestrian & !bicycle & !vehicle")


  epoch <- palms_epoch(palms)
  expect_equal(epoch, 15)

  palms_add_trajectory_field("mot",       "first(tripmot)")
  palms_add_trajectory_field("date",      "first(as.Date(datetime))")
  palms_add_trajectory_field("start",     "datetime[triptype==1]")
  palms_add_trajectory_field("end",       "datetime[triptype==4]")
  palms_add_trajectory_field("duration",  "as.numeric(difftime(end, start, units = \"secs\") + 15)")
  palms_add_trajectory_field("nonwear",   "sum(activityintensity < 0) * 15")
  palms_add_trajectory_field("wear",      "sum(activityintensity >= 0) * 15")
  palms_add_trajectory_field("sedentary", "sum(activityintensity == 0) * 15")
  palms_add_trajectory_field("light",     "sum(activityintensity == 1) * 15")
  palms_add_trajectory_field("moderate",  "sum(activityintensity == 2) * 15")
  palms_add_trajectory_field("vigorous",  "sum(activityintensity == 3) * 15")
  palms_add_trajectory_field("mvpa",      "moderate + vigorous")
  palms_add_trajectory_field("length",    "as.numeric(st_length(geometry))",  TRUE)
  palms_add_trajectory_field("speed",     "(length / duration) * 3.6", TRUE)

  expect_error(palms_add_trajectory_field("speed", "."))

  palms_add_trajectory_location("home_school", "at_home", "at_school")
  palms_add_trajectory_location("school_home", "at_school", "at_home")
  palms_add_trajectory_location("home_home", "at_home", "at_home")
  palms_add_trajectory_location("school_school", "at_school", "at_school")


  palms_add_multimodal_field(c("duration", "nonwear", "wear", "sedentary", "light",
                               "moderate", "vigorous", "mvpa", "length"), "sum")
  palms_add_multimodal_field("speed", "mean")


  context("Testing config tables")
  expect_length(unlist(palmsplus_domains), 8)
  expect_length(unlist(palmsplus_fields), 54)
  expect_length(unlist(trajectory_fields), 42)
  expect_length(unlist(trajectory_locations), 12)
  expect_length(unlist(multimodal_fields), 20)

  palms_remove_tables()
  palms_load_defaults(epoch)
  palms_add_domain("d_all",       "1")


  context("Testing build_palmsplus")

  palmsplus <- palms_build_palmsplus(palms, verbose = FALSE)
  expect_equal(sum(palmsplus$mvpa), 791)


  context("Testing build_days")

  days <- palms_build_days(palmsplus, verbose = FALSE)
  expect_equal(round(mean(days$d_all_mvpa, na.rm = TRUE), 2), 21.97)

  context("Testing build_trajectories")

  trajectories <- palms_build_trajectories(palmsplus)
  expect_equal(nrow(trajectories), 38)
  #expect_equal(sum(trajectories$home_school), 4)
  #expect_equal(sum(trajectories$school_home), 1)

  context("Testing build_multimodal")

  multimodal <- palms_build_multimodal(trajectories, 200, 10, verbose = FALSE)
  expect_equal(nrow(multimodal), 31)
  expect_equal(sum(multimodal$n_segments), nrow(trajectories))
  #expect_equal(ncol(multimodal), 42)
  #expect_equal(sum(multimodal$school_school), 15)

})

