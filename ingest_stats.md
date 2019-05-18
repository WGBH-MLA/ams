```
# Get the number of each ActiveFedora::Base descendant, sorted. Add the total sum as well.
sorted_counts = ActiveFedora::Base.descendants.map { |klass| [klass, klass.count] }.to_h.sort_by { |klass, count| count }.to_h
sorted_counts['TOTAL'] = sorted_counts.values.sum

# Get the total of AMS models
ams_classes = [Asset, DigitalInstantiation, PhysicalInstantiation, EssenceTrack, Contribution]
sorted_counts['AMS Records'] = ams_classes.map{|klass| sorted_counts[klass] }.sum


pp sorted_counts

{
  Collection=>0,
  FileSet=>0,
  Hydra::AccessControls::Embargo=>0,
  Hydra::AccessControls::Lease=>0,
  BatchUploadItem=>0,
  ActiveFedora::DirectContainer=>0,
  AdminSet=>1,
  PhysicalInstantiation=>1531,
  Asset=>2967,
  Contribution=>3321,
  DigitalInstantiation=>5851,
  ActiveFedora::Aggregation::ListSource=>8350,
  ActiveFedora::Container=>8354,
  ActiveFedora::IndirectContainer=>8354,
  Hydra::AccessControl=>13823,
  EssenceTrack=>14827,
  ActiveFedora::Aggregation::Proxy=>25039,
  Hydra::AccessControls::AccessControlList=>27489,
  Hydra::AccessControls::Permission=>27489,
  "TOTAL"=>147396,
  "AMS Records"=>28497
}



# Convert the counts into percentages of the total.
sorted_percentages = sorted_counts.map{|k,v| [k, "#{((v.to_f/sorted_counts["TOTAL"].to_f).round(3) * 100)}%"]}.to_h
pp sorted_percentages


{
  Collection=>"0.0%",
  FileSet=>"0.0%",
  Hydra::AccessControls::Embargo=>"0.0%",
  Hydra::AccessControls::Lease=>"0.0%",
  BatchUploadItem=>"0.0%",
  ActiveFedora::DirectContainer=>"0.0%",
  AdminSet=>"0.0%",
  PhysicalInstantiation=>"1.0%",
  Asset=>"2.0%",
  Contribution=>"2.3%",
  DigitalInstantiation=>"4.0%",
  ActiveFedora::Aggregation::ListSource=>"5.7%",
  ActiveFedora::Container=>"5.7%",
  ActiveFedora::IndirectContainer=>"5.7%",
  Hydra::AccessControl=>"9.4%",
  EssenceTrack=>"10.100000000000001%",
  ActiveFedora::Aggregation::Proxy=>"17.0%",
  Hydra::AccessControls::AccessControlList=>"18.6%",
  Hydra::AccessControls::Permission=>"18.6%",
  "TOTAL"=>"100.0%",
  "AMS Records"=>"19.3%"
}
```




Batch Migration Results:
