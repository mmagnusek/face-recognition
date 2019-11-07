require 'aws-sdk-rekognition'
require 'pry'
require 'unidecoder' # Remove accents
require 'active_support/core_ext/string/filters'
require 'dotenv/load'

class Recognition
  COLLECTION_ID = 'bbusers'

  Aws.config.update(
    region:      ENV['AWS_REGION'],
    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  )

  def index_faces
    resp = client.create_collection(collection_id: COLLECTION_ID)

    users.each do |user|
      resp = client.index_faces(
        collection_id:     COLLECTION_ID,
        external_image_id: user.to_ascii,
        image:             {
          s3_object: { bucket: COLLECTION_ID, name: "#{user}.jpg" }
        }
      )
    end
  end

  def compare(image)
    resp = client.search_faces_by_image(
      collection_id:        COLLECTION_ID,
      face_match_threshold: 80,
      max_faces:            1,
      image:                { bytes: image }
    )

    if matched = resp.face_matches.first
      { image_id: matched.face.external_image_id }
    else
      { error: 'Unauthorized - no face detected' }
    end
  end

  private

  def client
    @client ||= Aws::Rekognition::Client.new
  end

  def users
    %w(
      Adam_Hencze Adam_Kohout Adam_Zahumenský Antonín_Pleskač Dan_Hamerník
      Dan_Hamerník2 David_Čáp David_Grundel Dávid_Lipták David_Thompson
      Denis_Radabolski Dominika_Lentharova Duc_Nguyen_Bá Eliska_Přichystalová
      Eva_Šálková Filip_Fábišík Filip_Mrhálek Filip_Výborný Hong_Anh_Duong
      Jakub_Chrtek Jakub_Šnorbert Jan_Smejkal Ján_Suroviak Jana_Kantorová
      Jana_Pekárková Jiří_Brhel Jiří_Fiala Jiří_Zajpt Johana_Přibíková
      Jozef_Matúš Kamila_Szabóová Karel_Pařízek Kateřina_Vacuíková
      Kateřina_Valuchová Klára_Vojtová Kristina_Bradićová Ladislav_Škvarka
      Lucie_Dandová Lucie_Doubicová Lucie_Stoberová Lukáš_Hrachovina
      Marek_Bendík Markéta_Tupá Martin_Hora Martin_Magnusek Martin_Vorel
      Matěj_Balga Matěj_Koutský Michaela_Šišková Michal_Gritzbach Milian_Riedel
      Mirek_Mazal Monika_Králová Olena_Kostkina Ondřej_Matějka Ondřej_Rudolf
      Pavel_Soukup Pavel_Vachek Pavlo_Kryshenyk Petr_Rubáš Petr_Vais
      Renata_Nedělová Štěpán_Osoha Tereza_Šimková Tereza_Zíková Tomáš_Dundáček
      Tomáš_Vaisar Tomáš_Wagner Veronika_Pavlíková Vojtěch_Prokop
    )
  end
end

service = Recognition.new
service.index_faces
service.compare(File.read('test.jpg'))
