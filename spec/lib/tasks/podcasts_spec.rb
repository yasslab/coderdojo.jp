require 'rails_helper'
require 'rake'

RSpec.describe 'DojoCast:', podcast: true do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require 'tasks/podcasts'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    @rake[task].reenable
  end

  describe 'podcasts:upsert' do
    before :each do
      Podcast.destroy_all
      @episode = create(:podcast,
                 track_id:  111001,
                 title:     '999 - podcast 999',
                 duration:  '00:16:40',
                 permalink: 'podcast-999')
    end

    let(:task) { 'podcasts:upsert' }

    xit 'successfuly fetch from SoundCloud RSS' do
      allow_any_instance_of(Podcast).to receive(:id).and_return(
        [
          { 'id'            => 123456001,
            'title'         => '999 - podcast title',
            'description'   => '説明 999',
            'content_size'  => 124542711,
            'duration'      => 5189815,
            'user_id'       => 123456789,
            'permalink'     => 'podcast-999',
            'permalink_url' => 'https://soundcloud.com/coderdojojp/podcast-999',
            'created_at'    => '2099/01/23 01:00:00 +0000' }
        ]
      )

      # before
      expect(Podcast.count).to eq(1)
      before_ids = Podcast.ids

      # exec
      expect(@rake[task].invoke).to be_truthy

      # after
      expect(Podcast.count).not_to eq(1)
      new_records = Podcast.where.not(id: before_ids)
      expect(new_records.count).not_to eq(1)
      first_track = new_records.find(1)

      expect(first_track.track_id).to       eq(614641407)
      expect(first_track.title).to          eq('001 - 日本の CoderDojo の成り立ち')
      expect(first_track.description).to    start_with('jishiha')
      expect(first_track.content_size).to   eq(22887860)
      expect(first_track.duration).to       eq('00:47:37')
      expect(first_track.permalink).to      eq('dojocast-1')
      expect(first_track.permalink_url).to  eq('https://soundcloud.com/coderdojo-japan/dojocast-1')
      expect(first_track.published_date).to eq('2017-03-25'.to_date)
    end

    it 'failed to fetch from SoundCloud RSS' do
      allow_any_instance_of(Podcast).to receive(:id).and_return(
        [
          { 'id'            => 123456001,
            'title'         => 'podcast title 001',
            'description'   => '説明 001',
            'content_size'  => 124542711,
            'duration'      => 5189815,
            'user_id'       => 123456789,
            'permalink'     => 'podcast-001',
            'permalink_url' => 'https://soundcloud.com/coderdojojp/podcast-001',
            'created_at'    => '2019/01/23 01:00:00 +0000' }
        ]
      )

      # before
      expect(Podcast.count).to eq(1)
      before_ids = Podcast.ids

      # after
      expect(Podcast.count).to eq(1)
      new_records = Podcast.where.not(id: before_ids)
      expect(new_records.count).to eq(0)
    end
  end
end
