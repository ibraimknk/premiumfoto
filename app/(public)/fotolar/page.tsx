'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'

interface ImageItem {
  name: string
  url: string
  fullUrl: string
}

export default function FotolarPage() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [images, setImages] = useState<ImageItem[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedImage, setSelectedImage] = useState<ImageItem | null>(null)

  // Sayfa yüklendiğinde şifre kontrolü
  useEffect(() => {
    const savedAuth = localStorage.getItem('fotolar_auth')
    if (savedAuth === 'oxelio2024') {
      setIsAuthenticated(true)
    }
    loadImages()
  }, [])

  // Fotoğrafları yükle
  const loadImages = async () => {
    try {
      const response = await fetch('/api/uploads/list')
      const data = await response.json()
      if (data.success) {
        setImages(data.images || [])
      }
    } catch (error) {
      console.error('Fotoğraflar yüklenemedi:', error)
    } finally {
      setLoading(false)
    }
  }

  // Şifre kontrolü
  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (password === 'oxelio2024') {
      setIsAuthenticated(true)
      localStorage.setItem('fotolar_auth', 'oxelio2024')
      setError('')
    } else {
      setError('Yanlış şifre!')
      setPassword('')
    }
  }

  // Çıkış
  const handleLogout = () => {
    setIsAuthenticated(false)
    localStorage.removeItem('fotolar_auth')
    setPassword('')
  }

  // Robots meta tag ekle
  useEffect(() => {
    const metaRobots = document.querySelector('meta[name="robots"]')
    if (metaRobots) {
      metaRobots.setAttribute('content', 'noindex, nofollow')
    } else {
      const meta = document.createElement('meta')
      meta.name = 'robots'
      meta.content = 'noindex, nofollow'
      document.head.appendChild(meta)
    }
  }, [])

  // Şifre ekranı
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 to-gray-800">
          <div className="bg-white rounded-lg shadow-2xl p-8 w-full max-w-md">
            <h1 className="text-3xl font-bold text-center mb-6 text-gray-800">
              🔒 Şifreli Galeri
            </h1>
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                  Şifre
                </label>
                <input
                  type="password"
                  id="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
                  placeholder="Şifrenizi girin"
                  autoFocus
                />
              </div>
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                  {error}
                </div>
              )}
              <button
                type="submit"
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg transition duration-200"
              >
                Giriş Yap
              </button>
            </form>
          </div>
        </div>
      </>
    )
  }

  // Galeri ekranı
  return (
    <div className="min-h-screen bg-gray-100">
        {/* Header */}
        <header className="bg-white shadow-sm sticky top-0 z-10">
          <div className="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
            <h1 className="text-2xl font-bold text-gray-800">📸 Fotoğraf Galerisi</h1>
            <button
              onClick={handleLogout}
              className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition duration-200"
            >
              Çıkış
            </button>
          </div>
        </header>

        {/* Galeri Grid */}
        <main className="max-w-7xl mx-auto px-4 py-8">
          {loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Fotoğraflar yükleniyor...</p>
            </div>
          ) : images.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-gray-600 text-lg">Henüz fotoğraf yüklenmemiş.</p>
            </div>
          ) : (
            <>
              <p className="text-gray-600 mb-6">
                Toplam {images.length} fotoğraf
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
                {images.map((image) => (
                  <div
                    key={image.name}
                    onClick={() => setSelectedImage(image)}
                    className="relative aspect-square cursor-pointer group overflow-hidden rounded-lg shadow-md hover:shadow-xl transition-all duration-300 transform hover:scale-105"
                  >
                    <Image
                      src={image.url}
                      alt={image.name}
                      fill
                      className="object-cover"
                      sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 20vw"
                      unoptimized
                    />
                    <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-300 flex items-center justify-center">
                      <span className="text-white opacity-0 group-hover:opacity-100 text-4xl transition-opacity">
                        🔍
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}
        </main>

        {/* Modal - Büyük Fotoğraf */}
        {selectedImage && (
          <div
            className="fixed inset-0 bg-black bg-opacity-90 z-50 flex items-center justify-center p-4"
            onClick={() => setSelectedImage(null)}
          >
            <div className="relative max-w-7xl max-h-full">
              <button
                onClick={() => setSelectedImage(null)}
                className="absolute top-4 right-4 text-white hover:text-gray-300 text-4xl font-bold z-10 bg-black bg-opacity-50 rounded-full w-12 h-12 flex items-center justify-center"
              >
                ×
              </button>
              <div className="relative w-full h-full">
                <img
                  src={selectedImage.fullUrl}
                  alt={selectedImage.name}
                  className="max-w-full max-h-[90vh] object-contain mx-auto"
                />
              </div>
              <p className="text-white text-center mt-4 text-sm">
                {selectedImage.name}
              </p>
            </div>
          </div>
        )}
      </div>
  )
}

