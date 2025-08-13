enum MissionSupport {
  start,
  period,
  status,
  config,
  configTrigger,
  epoch,
  time,
  next,
  stop,
  checkPeriod,
  advertisingRate,
  waitRelease,
  radioOn,
  noRecord,
  startAbove,
  startBelow,
  startOnChannel,
  recordCH0,
  recordCH1,
  recordCH2,
  recordCH3,
  advertiseCH0factory,
  advertiseCH0user,
  advertiseCH1factory,
  advertiseCH1user,
  advertiseCH2factory,
  advertiseCH2user,
  advertiseCH3factory,
  advertiseCH3user,
}

enum MissionField {
  delay, // start delay (seconds)
  frequency, // acquisition period
  duration, // mission duration
  checkPeriod, // checkPeriod for triggers
  advRate, // advertising rate
  // Channel 0 options
  enableCh0Raw,
  enableCh0Factory,
  enableCh0User,
  // Channel 1 options
  enableCh1Raw,
  enableCh1Factory,
  enableCh1User,
  // Channel 2 options (future expansion)
  enableCh2Raw,
  enableCh2Factory,
  enableCh2User,
  // Channel 3 options (future expansion)
  enableCh3Raw,
  enableCh3Factory,
  enableCh3User,
  // Trigger fields
  startAbove, // trigger threshold above
  startBelow, // trigger threshold below
  startOnChannel, // trigger on channel change
}

const Map<MissionField, List<MissionSupport>> missionFieldCapabilities = {
  MissionField.delay: [MissionSupport.start],
  MissionField.frequency: [MissionSupport.period],
  MissionField.duration: [MissionSupport.stop],
  MissionField.checkPeriod: [MissionSupport.checkPeriod],
  MissionField.advRate: [MissionSupport.advertisingRate],
  // Channel 0 mappings
  MissionField.enableCh0Raw: [MissionSupport.recordCH0],
  MissionField.enableCh0Factory: [MissionSupport.advertiseCH0factory],
  MissionField.enableCh0User: [MissionSupport.advertiseCH0user],
  // Channel 1 mappings
  MissionField.enableCh1Raw: [MissionSupport.recordCH1],
  MissionField.enableCh1Factory: [MissionSupport.advertiseCH1factory],
  MissionField.enableCh1User: [MissionSupport.advertiseCH1user],
  // Channel 2 mappings (future expansion)
  MissionField.enableCh2Raw: [MissionSupport.recordCH2],
  MissionField.enableCh2Factory: [MissionSupport.advertiseCH2factory],
  MissionField.enableCh2User: [MissionSupport.advertiseCH2user],
  // Channel 3 mappings (future expansion)
  MissionField.enableCh3Raw: [MissionSupport.recordCH3],
  MissionField.enableCh3Factory: [MissionSupport.advertiseCH3factory],
  MissionField.enableCh3User: [MissionSupport.advertiseCH3user],
  // Trigger mappings
  MissionField.startAbove: [MissionSupport.startAbove],
  MissionField.startBelow: [MissionSupport.startBelow],
  MissionField.startOnChannel: [MissionSupport.startOnChannel],
};
