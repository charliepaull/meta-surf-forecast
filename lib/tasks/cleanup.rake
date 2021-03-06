# frozen_string_literal: true

namespace :cleanup do
  desc 'remove api_requests not attached to forecasts'
  task prune_api_requests: :environment do
    ApiRequest.where.not('id in (SELECT api_request_id FROM surfline_lolas UNION SELECT api_request_id FROM surfline_nearshores UNION SELECT api_request_id FROM spitcasts UNION SELECT api_request_id FROM msws)').delete_all
  end

  desc 'Remove forecasts that are in the past'
  task prune_past_forecasts: :environment do
    SurflineLola.unscoped.where('timestamp < now()').delete_all
    SurflineNearshore.unscoped.where('timestamp < now()').delete_all
    Msw.unscoped.where('timestamp < now()').delete_all
    Spitcast.unscoped.where('timestamp < now()').delete_all
    Rake::Task['cleanup:prune_api_requests'].invoke
  end

  desc 'Remove forecasts that are in the future'
  task wipe_future_forecasts: :environment do
    SurflineLola.unscoped.where('timestamp > now()').delete_all
    SurflineNearshore.unscoped.where('timestamp > now()').delete_all
    Msw.unscoped.where('timestamp > now()').delete_all
    Spitcast.unscoped.where('timestamp > now()').delete_all
    Rake::Task['cleanup:prune_api_requests'].invoke
  end
end
