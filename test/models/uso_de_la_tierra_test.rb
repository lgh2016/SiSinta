require './test/test_helper'

class UsoDeLaTierraTest < ActiveSupport::TestCase
  subject { build(:uso_de_la_tierra) }

  describe 'validaciones' do
    it 'es válido' do
      subject.must_be :valid?
    end

    it 'require valor' do
      build(:uso_de_la_tierra, valor: nil).wont_be :valid?
    end
  end

  describe 'asociaciones' do
    subject { create :uso_de_la_tierra }
    let(:perfil) { create :perfil, uso_de_la_tierra: subject }

    it 'se recorre en ambos sentidos' do
      perfil.uso_de_la_tierra.must_equal subject

      subject.perfiles.first.must_equal perfil
    end
  end
end
