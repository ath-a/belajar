// Aplikasi React untuk hafalan Hiragana dan abjad Jerman
import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";

const hiraganaData = [
  { kana: "あ", romaji: "a", audio: "/audio/a.mp3" },
  { kana: "い", romaji: "i", audio: "/audio/i.mp3" },
  { kana: "う", romaji: "u", audio: "/audio/u.mp3" },
  { kana: "え", romaji: "e", audio: "/audio/e.mp3" },
  { kana: "お", romaji: "o", audio: "/audio/o.mp3" },
  { kana: "か", romaji: "ka", audio: "/audio/ka.mp3" },
  { kana: "き", romaji: "ki", audio: "/audio/ki.mp3" },
  { kana: "く", romaji: "ku", audio: "/audio/ku.mp3" },
  { kana: "け", romaji: "ke", audio: "/audio/ke.mp3" },
  { kana: "こ", romaji: "ko", audio: "/audio/ko.mp3" },
];

const germanData = [
  { kana: "A", romaji: "ah", audio: "/audio_german/a.mp3" },
  { kana: "B", romaji: "beh", audio: "/audio_german/b.mp3" },
  { kana: "C", romaji: "tseh", audio: "/audio_german/c.mp3" },
  { kana: "D", romaji: "deh", audio: "/audio_german/d.mp3" },
  { kana: "E", romaji: "eh", audio: "/audio_german/e.mp3" },
  { kana: "F", romaji: "eff", audio: "/audio_german/f.mp3" },
];

export default function FlashcardsApp() {
  const [index, setIndex] = useState(0);
  const [showRomaji, setShowRomaji] = useState(false);
  const [mode, setMode] = useState("belajar"); // "belajar" atau "kuis"
  const [quizInput, setQuizInput] = useState("");
  const [quizResult, setQuizResult] = useState(null);
  const [score, setScore] = useState(0);
  const [language, setLanguage] = useState("jepang");

  const currentData = language === "jepang" ? hiraganaData : germanData;
  const { kana, romaji, audio } = currentData[index];

  const playAudio = () => {
    const audioObj = new Audio(audio);
    audioObj.play();
  };

  const nextCard = () => {
    setIndex((prev) => (prev + 1) % currentData.length);
    setShowRomaji(false);
    setQuizInput("");
    setQuizResult(null);
  };

  const toggleRomaji = () => {
    setShowRomaji((prev) => !prev);
    playAudio();
  };

  const checkAnswer = () => {
    const correct = quizInput.trim().toLowerCase() === romaji;
    setQuizResult(correct);
    if (correct) setScore((s) => s + 1);
  };

  useEffect(() => {
    if (mode === "belajar") playAudio();
  }, [index, mode, language]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-6 bg-gradient-to-br from-pink-100 to-blue-100 p-4 transition-all">
      <div className="flex gap-2 mb-2">
        <Button onClick={() => setLanguage("jepang")} variant={language === "jepang" ? "default" : "outline"}>Bahasa Jepang</Button>
        <Button onClick={() => setLanguage("german")} variant={language === "german" ? "default" : "outline"}>Bahasa Jerman</Button>
      </div>
      <div className="flex gap-4 mb-4">
        <Button onClick={() => setMode("belajar")} variant={mode === "belajar" ? "default" : "outline"}>Belajar</Button>
        <Button onClick={() => setMode("kuis")} variant={mode === "kuis" ? "default" : "outline"}>Kuis</Button>
      </div>

      <motion.div
        initial={{ scale: 0.8, rotate: -5, opacity: 0 }}
        animate={{ scale: 1, rotate: 0, opacity: 1 }}
        transition={{ type: "spring", stiffness: 200, damping: 15 }}
      >
        <Card
          className="w-60 h-60 flex items-center justify-center text-6xl font-bold bg-white shadow-2xl rounded-2xl cursor-pointer hover:rotate-1 hover:shadow-xl transition-transform duration-300"
          onClick={toggleRomaji}
        >
          <CardContent className="flex items-center justify-center h-full">
            {mode === "belajar"
              ? showRomaji
                ? romaji
                : kana
              : kana}
          </CardContent>
        </Card>
      </motion.div>

      {mode === "belajar" && (
        <>
          <Button onClick={nextCard} className="text-white bg-indigo-600 hover:bg-indigo-700 px-6 py-2 rounded-full shadow-md">
            Kartu Selanjutnya
          </Button>
          <p className="text-sm text-gray-600">Klik kartu untuk melihat latin & dengar audio</p>
        </>
      )}

      {mode === "kuis" && (
        <div className="flex flex-col items-center gap-3 w-full max-w-xs">
          <input
            className="px-4 py-2 border rounded w-full text-center"
            type="text"
            placeholder="Masukkan romaji"
            value={quizInput}
            onChange={(e) => setQuizInput(e.target.value)}
          />
          <Button onClick={checkAnswer} className="bg-green-500 hover:bg-green-600 text-white">Cek Jawaban</Button>
          {quizResult !== null && (
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className={quizResult ? "text-green-600" : "text-red-600"}
            >
              {quizResult ? "Benar!" : `Salah. Jawaban: ${romaji}`}
            </motion.p>
          )}
          <p className="text-sm text-gray-600">Skor: {score}</p>
          <Button onClick={nextCard} className="bg-indigo-600 hover:bg-indigo-700 text-white">Soal Berikutnya</Button>
        </div>
      )}
    </div>
  );
}
